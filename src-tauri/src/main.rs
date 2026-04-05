// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::net::TcpStream;
use std::path::Path;
use std::process::{Child, Command, Stdio};
use std::sync::Mutex;
use std::time::{Duration, Instant};
use tauri::Manager;

const SERVER_PORT: u16 = 8001;
const APP_URL: &str = "http://127.0.0.1:8001/static/index.html";

static SIDECAR: Mutex<Option<Child>> = Mutex::new(None);

/// Recursively copy a directory tree from src to dst, overwriting existing files.
fn copy_dir_all(src: &Path, dst: &Path) -> std::io::Result<()> {
    std::fs::create_dir_all(dst)?;
    for entry in std::fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        let dst_path = dst.join(entry.file_name());
        if ty.is_dir() {
            copy_dir_all(&entry.path(), &dst_path)?;
        } else {
            std::fs::copy(entry.path(), &dst_path)?;
        }
    }
    Ok(())
}

/// Copy bundled project files from resource_dir to app_data_dir so jac has a
/// writable working directory (jac writes .jac/cache/ and .jac/data/ alongside
/// main.jac). Existing user data in .jac/data/ is never touched.
fn setup_project_dir(resource_dir: &Path, app_data_dir: &Path) {
    if let Err(e) = std::fs::create_dir_all(app_data_dir) {
        eprintln!("[setup] failed to create app_data_dir {app_data_dir:?}: {e}");
        return;
    }

    // Copy individual source files.
    for name in &["main.jac", "jac.toml"] {
        let src = resource_dir.join(name);
        let dst = app_data_dir.join(name);
        if src.exists() {
            if let Err(e) = std::fs::copy(&src, &dst) {
                eprintln!("[setup] copy {name} failed: {e}");
            }
        } else {
            eprintln!("[setup] resource missing: {src:?}");
        }
    }

    // Copy app/ directory tree (Jac server-side modules).
    let src_app = resource_dir.join("app");
    if src_app.exists() {
        if let Err(e) = copy_dir_all(&src_app, &app_data_dir.join("app")) {
            eprintln!("[setup] copy app/ failed: {e}");
        }
    } else {
        eprintln!("[setup] resource missing: {src_app:?}");
    }

    // Copy frontend dist (.jac/client/dist/).
    // We copy only dist/, never touching .jac/data/ or .jac/cache/ so that
    // the user's persistent graph storage is preserved across updates.
    let src_dist = resource_dir.join(".jac/client/dist");
    if src_dist.exists() {
        let dst_dist = app_data_dir.join(".jac/client/dist");
        if let Err(e) = copy_dir_all(&src_dist, &dst_dist) {
            eprintln!("[setup] copy frontend dist failed: {e}");
        }
    } else {
        eprintln!("[setup] resource missing: {src_dist:?}");
    }

    eprintln!("[setup] project files ready at {app_data_dir:?}");
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
        Err(e) => {
            eprintln!("[sidecar] resource_dir error: {e}");
            return;
        }
    };

    let app_data_dir = match app.path().app_data_dir() {
        Ok(d) => d,
        Err(e) => {
            eprintln!("[sidecar] app_data_dir error: {e}");
            return;
        }
    };

    // Extract bundled project files to a writable directory.
    setup_project_dir(&resource_dir, &app_data_dir);

    let script = if cfg!(windows) {
        resource_dir.join("binaries/jac-sidecar.bat")
    } else {
        resource_dir.join("binaries/jac-sidecar.sh")
    };

    if !script.exists() {
        eprintln!("[sidecar] script not found at {script:?} — start jac manually");
        return;
    }

    eprintln!("[sidecar] project dir: {app_data_dir:?}");

    let mut cmd = if cfg!(windows) {
        let mut c = Command::new("cmd");
        c.arg("/C").arg(&script);
        c
    } else {
        let mut c = Command::new("sh");
        c.arg(&script);
        c
    };
    cmd.arg(&app_data_dir)
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
