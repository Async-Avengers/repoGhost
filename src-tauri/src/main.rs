// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::process::{Command, Child, Stdio};
use std::sync::Mutex;
use tauri::Manager;

// Global storage for sidecar process
static SIDECAR_PROCESS: Mutex<Option<Child>> = Mutex::new(None);
static API_BASE_URL: Mutex<Option<String>> = Mutex::new(None);

/// User-configured base URL from jac.toml (empty = dynamic discovery)
const CONFIGURED_BASE_URL: &str = "http://127.0.0.1:8001";

fn find_and_start_sidecar(app: &tauri::AppHandle) -> Result<(), Box<dyn std::error::Error>> {
    // Set the API base URL
    {
        let mut url = API_BASE_URL.lock().unwrap();
        *url = Some(CONFIGURED_BASE_URL.to_string());
    }
    eprintln!("API base URL: {}", CONFIGURED_BASE_URL);

    // Find the sidecar script in bundled resources
    let resource_dir = app.path().resource_dir()?;
    let sidecar_path = if cfg!(windows) {
        resource_dir.join("binaries/jac-sidecar.bat")
    } else {
        resource_dir.join("binaries/jac-sidecar.sh")
    };

    if !sidecar_path.exists() {
        eprintln!("Sidecar not found at {:?} — backend must be started manually", sidecar_path);
        return Ok(());
    }

    // Walk up from the exe looking for main.jac; fall back to "main.jac" in cwd
    let module_path = std::env::current_exe()
        .ok()
        .and_then(|exe| {
            let mut dir = exe.parent()?.to_path_buf();
            loop {
                let candidate = dir.join("main.jac");
                if candidate.exists() {
                    return Some(candidate);
                }
                if !dir.pop() {
                    return None;
                }
            }
        })
        .unwrap_or_else(|| std::path::PathBuf::from("main.jac"));

    let mut cmd = if cfg!(windows) {
        let mut c = Command::new("cmd");
        c.arg("/C").arg(&sidecar_path);
        c
    } else {
        let mut c = Command::new("sh");
        c.arg(&sidecar_path);
        c
    };
    cmd.arg("--module-path").arg(&module_path);
    cmd.stdout(Stdio::null());
    cmd.stderr(Stdio::inherit());

    match cmd.spawn() {
        Ok(child) => {
            eprintln!("Sidecar started (module: {:?}), connecting to {}", module_path, CONFIGURED_BASE_URL);
            let mut process = SIDECAR_PROCESS.lock().unwrap();
            *process = Some(child);
        }
        Err(e) => {
            eprintln!("Failed to start sidecar: {}", e);
            return Err(Box::new(e));
        }
    }

    Ok(())
}

fn stop_sidecar() {
    let mut process = SIDECAR_PROCESS.lock().unwrap();
    if let Some(mut child) = process.take() {
        let _ = child.kill();
        let _ = child.wait();
        eprintln!("Sidecar stopped");
    }
}

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            // Start sidecar to discover dynamic port
            if let Err(e) = find_and_start_sidecar(app.handle()) {
                eprintln!("Warning: Could not start sidecar: {}", e);
            }

            // Build initialization script with API base URL
            let init_js = {
                let url = API_BASE_URL.lock().unwrap();
                match *url {
                    Some(ref base_url) => {
                        eprintln!("Injecting API base URL: {}", base_url);
                        format!(
                            "globalThis.__JAC_API_BASE_URL__ = '{}';",
                            base_url
                        )
                    }
                    None => String::new(),
                }
            };

            // Create window with initialization_script (runs BEFORE page JS)
            let mut builder = tauri::WebviewWindowBuilder::new(
                app,
                "main",
                tauri::WebviewUrl::App("index.html".into())
            )
            .title("RepoGhost")
            .inner_size(1200.0, 800.0)
            .min_inner_size(800.0, 600.0)
            .resizable(true);

            if !init_js.is_empty() {
                builder = builder.initialization_script(&init_js);
            }

            builder.build()?;

            Ok(())
        })
        .on_window_event(|_window, event| {
            // Clean up sidecar when last window closes
            if matches!(event, tauri::WindowEvent::CloseRequested { .. }) {
                stop_sidecar();
            }
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");

    // Ensure sidecar is stopped on exit
    stop_sidecar();
}
