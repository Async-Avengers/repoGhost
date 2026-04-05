// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::net::TcpStream;
use std::process::{Child, Command, Stdio};
use std::sync::Mutex;
use std::time::{Duration, Instant};
use tauri::Manager;

const SERVER_PORT: u16 = 8001;
const APP_URL: &str = "http://127.0.0.1:8001/static/index.html";

static SIDECAR: Mutex<Option<Child>> = Mutex::new(None);

/// Walk up from the running executable to find the directory containing main.jac.
fn find_project_dir() -> Option<std::path::PathBuf> {
    let exe = std::env::current_exe().ok()?;
    let mut dir = exe.parent()?.to_path_buf();
    loop {
        if dir.join("main.jac").exists() {
            return Some(dir);
        }
        if !dir.pop() {
            return None;
        }
    }
}

/// Block until port 8001 accepts a TCP connection or the timeout elapses.
fn wait_for_server(timeout: Duration) -> bool {
    let deadline = Instant::now() + timeout;
    while Instant::now() < deadline {
        if TcpStream::connect(("127.0.0.1", SERVER_PORT)).is_ok() {
            // Brief pause so the HTTP layer is fully initialised.
            std::thread::sleep(Duration::from_millis(400));
            return true;
        }
        std::thread::sleep(Duration::from_millis(300));
    }
    false
}

fn start_sidecar(app: &tauri::AppHandle) {
    let resource_dir = match app.path().resource_dir() {
        Ok(d) => d,
        Err(e) => { eprintln!("[sidecar] resource_dir error: {e}"); return; }
    };

    let script = if cfg!(windows) {
        resource_dir.join("binaries/jac-sidecar.bat")
    } else {
        resource_dir.join("binaries/jac-sidecar.sh")
    };

    if !script.exists() {
        eprintln!("[sidecar] script not found at {script:?} — start jac manually");
        return;
    }

    let project_dir = find_project_dir()
        .unwrap_or_else(|| std::env::current_dir().unwrap_or_default());

    eprintln!("[sidecar] project dir: {project_dir:?}");

    let mut cmd = if cfg!(windows) {
        let mut c = Command::new("cmd");
        c.arg("/C").arg(&script);
        c
    } else {
        let mut c = Command::new("sh");
        c.arg(&script);
        c
    };
    cmd.arg(&project_dir)
        .stdout(Stdio::null())
        .stderr(Stdio::inherit());

    match cmd.spawn() {
        Ok(child) => {
            eprintln!("[sidecar] started (pid {})", child.id());
            *SIDECAR.lock().unwrap() = Some(child);
        }
        Err(e) => eprintln!("[sidecar] failed to start: {e}"),
    }
}

fn stop_sidecar() {
    if let Some(mut child) = SIDECAR.lock().unwrap().take() {
        let _ = child.kill();
        let _ = child.wait();
        eprintln!("[sidecar] stopped");
    }
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .setup(|app| {
            start_sidecar(app.handle());

            eprintln!("[app] waiting for server on port {SERVER_PORT}…");
            if wait_for_server(Duration::from_secs(30)) {
                eprintln!("[app] server ready → opening {APP_URL}");
            } else {
                eprintln!("[app] server did not start in time — opening anyway");
            }

            let url = APP_URL.parse::<url::Url>().expect("invalid APP_URL");
            tauri::WebviewWindowBuilder::new(app, "main", tauri::WebviewUrl::External(url))
                .title("RepoGhost")
                .inner_size(1200.0, 800.0)
                .min_inner_size(800.0, 600.0)
                .resizable(true)
                .center()
                .build()?;

            Ok(())
        })
        .on_window_event(|_window, event| {
            if matches!(event, tauri::WindowEvent::CloseRequested { .. }) {
                stop_sidecar();
            }
        })
        .run(tauri::generate_context!())
        .expect("error running RepoGhost");

    stop_sidecar();
}
