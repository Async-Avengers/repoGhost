#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .setup(|app| {
            tauri::WebviewWindowBuilder::new(
                app,
                "main",
                tauri::WebviewUrl::App("index.html".into()),
            )
            .title("RepoGhost")
            .inner_size(400.0, 844.0)
            .min_inner_size(400.0, 844.0)
            .max_inner_size(400.0, 844.0)
            .resizable(false)
            .center()
            .build()?;

            // TODO: production sidecar — bundle the Jac API server binary at
            // src-tauri/binaries/jac-server-<target-triple> and uncomment below,
            // then add it to tauri.conf.json `bundle.externalBin`.
            //
            // In dev: run `jac start --dev main.jac` in a separate terminal,
            // then `cargo tauri dev` to open the window against localhost:8000.
            //
            // #[cfg(not(debug_assertions))]
            // {
            //     use tauri_plugin_shell::ShellExt;
            //     app.shell()
            //         .sidecar("jac-server")
            //         .expect("jac-server sidecar not bundled")
            //         .args(["start", "main.jac"])
            //         .spawn()
            //         .expect("failed to start jac-server sidecar");
            // }

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error running RepoGhost")
}
