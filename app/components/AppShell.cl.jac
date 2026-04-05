import from typing { Any }
sv import from app.orchestration.workflow { run_workflow, query_run_artifacts }
sv import from app.services.llm_runtime { supported_llm_models, default_llm_model }
import from app.components.SetupShell { SetupShell }
import from app.components.WidgetShell { WidgetShell }

glob STORAGE_SETUP_COMPLETE: str = "repoghost.setup.complete";
glob STORAGE_API_KEY: str = "repoghost.llm.api_key";
glob STORAGE_MODEL: str = "repoghost.llm.model";
glob STORAGE_REMEMBER: str = "repoghost.llm.remember";
glob STORAGE_THEME: str = "repoghost.ui.theme";
glob STORAGE_CONTRAST: str = "repoghost.ui.contrast";

def mark_used(value: Any) -> None {
    if value {
        return;
    }
}

def bool_text(value: bool) -> str {
    if value {
        return "true";
    }
    return "false";
}

def app_shell_class(theme_mode: str, contrast_mode: str) -> str {
    theme_class: str = "theme-light" if theme_mode == "light" else "theme-dark";
    contrast_class: str = "contrast-high" if contrast_mode == "high" else "contrast-standard";
    return "repoghost-screen " + theme_class + " " + contrast_class + " min-h-screen overflow-hidden px-3 py-4";
}

def model_option_rows(model_options: list[str]) -> list[JsxElement] {
    rows: list[JsxElement] = [];
    for item in model_options {
        rows.append(<option key={item} value={item}>{item}</option>);
    }
    if len(rows) == 0 {
        rows.append(<option key="gpt-4o-mini" value="gpt-4o-mini">gpt-4o-mini</option>);
    }
    return rows;
}

async def fetch_workflow_bundle(repo_path: str, meeting_text: str, prompt: str, mode: str, user_api_key: str, user_model: str) -> Any {
    result: Any = await run_workflow(repo_path, meeting_text, prompt, mode, user_api_key, user_model);
    return result;
}

async def fetch_run_answer(prompt: str, bundle: Any, user_api_key: str, user_model: str) -> str {
    answer: str = await query_run_artifacts(prompt, bundle, user_api_key, user_model);
    return answer;
}

async def fetch_model_options() -> list[str] {
    options: list[str] = await supported_llm_models();
    return options;
}

async def fetch_default_model() -> str {
    model_name: str = await default_llm_model();
    return model_name;
}

def:pub AppShell() -> JsxElement {
    has repoPath: str = "";
    has meetingText: str = "";
    has contextFileName: str = "";
    has mode: str = "feature_plan";
    has processingContext: bool = False;
    has answeringQuery: bool = False;
    has error: str = "";
    has bundle: Any = None;
    has runState: Any = None;
    has ownershipData: list[Any] = [];
    has decisionsData: list[Any] = [];
    has activeWidgetTab: str = "context";
    has statusMessage: str = "";
    has hasProcessedContext: bool = False;
    has followUpPrompt: str = "";
    has followUpHistory: list[dict[str, str]] = [];
    has setupLoaded: bool = False;
    has setupComplete: bool = False;
    has rememberSettings: bool = True;
    has userApiKey: str = "";
    has selectedModel: str = "gpt-4o-mini";
    has modelOptions: list[str] = ["gpt-4o-mini"];
    has themeMode: str = "dark";
    has contrastMode: str = "standard";
    has settingsEditorOpen: bool = False;
    has confirmingNewGhost: bool = False;
    has storageHandle: Any = None;

    def storage_get(key: str) -> str {
        if storageHandle is None {
            return "";
        }
        raw_value: Any = storageHandle.getItem(key);
        if raw_value is None {
            return "";
        }
        return str(raw_value);
    }

    def storage_set(key: str, value: str) -> None {
        if storageHandle is None {
            return;
        }
        storageHandle.setItem(key, value);
    }

    def storage_remove(key: str) -> None {
        if storageHandle is None {
            return;
        }
        storageHandle.removeItem(key);
    }

    def stored_bool(key: str, fallback: bool = False) -> bool {
        raw_value: str = storage_get(key);
        if not raw_value {
            return fallback;
        }
        return raw_value == "true";
    }

    def persist_theme_preferences() -> None {
        storage_set(STORAGE_THEME, themeMode);
        storage_set(STORAGE_CONTRAST, contrastMode);
    }

    def persist_llm_preferences() -> None {
        storage_set(STORAGE_SETUP_COMPLETE, "true");
        storage_set(STORAGE_REMEMBER, bool_text(rememberSettings));
        if rememberSettings {
            storage_set(STORAGE_MODEL, selectedModel);
            if userApiKey {
                storage_set(STORAGE_API_KEY, userApiKey);
            } else {
                storage_remove(STORAGE_API_KEY);
            }
            return;
        }
        storage_remove(STORAGE_API_KEY);
        storage_remove(STORAGE_MODEL);
    }

    def clear_run_artifacts() -> None {
        bundle = None;
        runState = None;
        ownershipData = [];
        decisionsData = [];
        hasProcessedContext = False;
        followUpPrompt = "";
        followUpHistory = [];
        activeWidgetTab = "context";
        statusMessage = "";
        mark_used(bundle);
        mark_used(runState);
        mark_used(ownershipData);
        mark_used(decisionsData);
        mark_used(hasProcessedContext);
        mark_used(followUpPrompt);
        mark_used(followUpHistory);
        mark_used(activeWidgetTab);
        mark_used(statusMessage);
    }

    def reset_session() -> None {
        clear_run_artifacts();
        repoPath = "";
        meetingText = "";
        contextFileName = "";
        followUpPrompt = "";
        error = "";
        statusMessage = "";
        processingContext = False;
        answeringQuery = False;
        settingsEditorOpen = False;
        confirmingNewGhost = False;
        mark_used(repoPath);
        mark_used(meetingText);
        mark_used(contextFileName);
        mark_used(followUpPrompt);
        mark_used(error);
        mark_used(statusMessage);
        mark_used(processingContext);
        mark_used(answeringQuery);
        mark_used(settingsEditorOpen);
        mark_used(confirmingNewGhost);
    }

    async can with entry {
        storageHandle = localStorage; # jac:ignore[W2001]
        mark_used(storageHandle);
        savedTheme: str = storage_get(STORAGE_THEME);
        savedContrast: str = storage_get(STORAGE_CONTRAST);
        savedApiKey: str = storage_get(STORAGE_API_KEY);
        savedModel: str = storage_get(STORAGE_MODEL);
        if savedTheme in ["dark", "light"] {
            themeMode = savedTheme;
            mark_used(themeMode);
        }
        if savedContrast in ["standard", "high"] {
            contrastMode = savedContrast;
            mark_used(contrastMode);
        }
        rememberSettings = stored_bool(STORAGE_REMEMBER, True);
        setupComplete = stored_bool(STORAGE_SETUP_COMPLETE, False);
        mark_used(rememberSettings);
        mark_used(setupComplete);
        if savedApiKey {
            userApiKey = savedApiKey;
            mark_used(userApiKey);
        }
        if savedModel {
            selectedModel = savedModel;
            mark_used(selectedModel);
        }
        try {
            fetchedModels: list[str] = await fetch_model_options();
            if len(fetchedModels) > 0 {
                modelOptions = fetchedModels;
                mark_used(modelOptions);
            }
            defaultModelName: str = await fetch_default_model();
            if defaultModelName and (not selectedModel or selectedModel == "gpt-4o-mini") {
                selectedModel = defaultModelName;
                mark_used(selectedModel);
            }
        } except RuntimeError {
        } except ValueError {
        } except TypeError {
        } except OSError {
        }
        if not selectedModel and len(modelOptions) > 0 {
            selectedModel = modelOptions[0];
            mark_used(selectedModel);
        }
        if selectedModel not in modelOptions and len(modelOptions) > 0 {
            selectedModel = modelOptions[0];
            mark_used(selectedModel);
        }
        setupLoaded = True;
        mark_used(setupLoaded);
    }

    can with [themeMode, contrastMode] entry {
        if not setupLoaded {
            return;
        }
        persist_theme_preferences();
    }

    async def submit_setup() -> None {
        if not selectedModel and len(modelOptions) > 0 {
            selectedModel = modelOptions[0];
            mark_used(selectedModel);
        }
        persist_llm_preferences();
        setupComplete = True;
        settingsEditorOpen = False;
        error = "";
        mark_used(setupComplete);
        mark_used(settingsEditorOpen);
        mark_used(error);
    }

    async def process_context() -> None {
        if not repoPath {
            error = "Add a repo path before processing context.";
            mark_used(error);
            return;
        }
        clear_run_artifacts();
        processingContext = True;
        error = "";
        statusMessage = "Processing context";
        settingsEditorOpen = False;
        mark_used(processingContext);
        mark_used(error);
        mark_used(statusMessage);
        mark_used(settingsEditorOpen);
        try {
            nextBundle: Any = await fetch_workflow_bundle(repoPath, meetingText, "", mode, userApiKey, selectedModel);
            bundle = nextBundle;
            runState = nextBundle.run_state if nextBundle else None;
            ownershipData = nextBundle.ownership if nextBundle else [];
            decisionsData = nextBundle.decisions if nextBundle else [];
            hasProcessedContext = True;
            if nextBundle and nextBundle.run_state and nextBundle.run_state.summary {
                statusMessage = nextBundle.run_state.summary;
                mark_used(statusMessage);
            } else {
                statusMessage = "Context processed";
                mark_used(statusMessage);
            }
            mark_used(bundle);
            mark_used(runState);
            mark_used(ownershipData);
            mark_used(decisionsData);
            mark_used(hasProcessedContext);
            mark_used(statusMessage);
        } except ValueError as e {
            error = str(e);
            statusMessage = "Context processing failed";
            mark_used(error);
            mark_used(statusMessage);
        } except RuntimeError as e {
            error = str(e);
            statusMessage = "Context processing failed";
            mark_used(error);
            mark_used(statusMessage);
        } except TypeError as e {
            error = str(e);
            statusMessage = "Context processing failed";
            mark_used(error);
            mark_used(statusMessage);
        } except OSError as e {
            error = str(e);
            statusMessage = "Context processing failed";
            mark_used(error);
            mark_used(statusMessage);
        }
        processingContext = False;
        mark_used(processingContext);
    }

    async def ask_about_run() -> None {
        if not hasProcessedContext or not bundle {
            error = "Process context before asking follow-up questions.";
            mark_used(error);
            return;
        }
        if not followUpPrompt {
            error = "Add a follow-up prompt for the current run.";
            mark_used(error);
            return;
        }
        answeringQuery = True;
        error = "";
        mark_used(answeringQuery);
        mark_used(error);
        try {
            question: str = followUpPrompt;
            answer: str = await fetch_run_answer(question, bundle, userApiKey, selectedModel);
            followUpHistory = followUpHistory + [
                {"role": "user", "content": question},
                {"role": "assistant", "content": answer}
            ];
            followUpPrompt = "";
            mark_used(followUpHistory);
            mark_used(followUpPrompt);
        } except ValueError as e {
            error = str(e);
            mark_used(error);
        } except RuntimeError as e {
            error = str(e);
            mark_used(error);
        } except TypeError as e {
            error = str(e);
            mark_used(error);
        } except OSError as e {
            error = str(e);
            mark_used(error);
        }
        answeringQuery = False;
        mark_used(answeringQuery);
    }

    def update_repo_path(next_path: str) -> None {
        repoPath = next_path;
        mark_used(repoPath);
        if error {
            error = "";
            mark_used(error);
        }
        confirmingNewGhost = False;
        mark_used(confirmingNewGhost);
        clear_run_artifacts();
    }

    def update_meeting_text(next_text: str) -> None {
        meetingText = next_text;
        contextFileName = "";
        mark_used(meetingText);
        mark_used(contextFileName);
        if error {
            error = "";
            mark_used(error);
        }
        confirmingNewGhost = False;
        mark_used(confirmingNewGhost);
        clear_run_artifacts();
    }

    def update_context_file_name(next_name: str) -> None {
        contextFileName = next_name;
        mark_used(contextFileName);
    }

    def update_follow_up_prompt(next_prompt: str) -> None {
        followUpPrompt = next_prompt;
        mark_used(followUpPrompt);
        if error {
            error = "";
            mark_used(error);
        }
    }

    def update_active_widget_tab(tab: str) -> None {
        activeWidgetTab = tab;
        mark_used(activeWidgetTab);
    }

    def update_user_api_key(next_key: str) -> None {
        userApiKey = next_key;
        mark_used(userApiKey);
    }

    def update_selected_model(next_model: str) -> None {
        selectedModel = next_model;
        mark_used(selectedModel);
        if setupComplete {
            persist_llm_preferences();
        }
    }

    def update_remember_settings(next_value: bool) -> None {
        rememberSettings = next_value;
        mark_used(rememberSettings);
    }

    def toggle_settings_editor() -> None {
        settingsEditorOpen = not settingsEditorOpen;
        confirmingNewGhost = False;
        mark_used(settingsEditorOpen);
        mark_used(confirmingNewGhost);
    }

    def save_api_settings() -> None {
        persist_llm_preferences();
        settingsEditorOpen = False;
        mark_used(settingsEditorOpen);
    }

    def clear_api_settings() -> None {
        userApiKey = "";
        settingsEditorOpen = False;
        storage_remove(STORAGE_API_KEY);
        if rememberSettings {
            persist_llm_preferences();
        }
        mark_used(userApiKey);
        mark_used(settingsEditorOpen);
    }

    def prompt_new_ghost() -> None {
        confirmingNewGhost = True;
        settingsEditorOpen = False;
        mark_used(confirmingNewGhost);
        mark_used(settingsEditorOpen);
    }

    def cancel_new_ghost() -> None {
        confirmingNewGhost = False;
        mark_used(confirmingNewGhost);
    }

    def confirm_new_ghost() -> None {
        reset_session();
    }

    def toggle_theme() -> None {
        if themeMode == "dark" {
            themeMode = "light";
        } else {
            themeMode = "dark";
        }
        mark_used(themeMode);
    }

    def toggle_contrast() -> None {
        if contrastMode == "high" {
            contrastMode = "standard";
        } else {
            contrastMode = "high";
        }
        mark_used(contrastMode);
    }

    shellLoading: bool = processingContext or answeringQuery;
    shellClass: str = app_shell_class(themeMode, contrastMode);
    headerIconButtonClass: str = "inline-flex h-10 w-10 items-center justify-center rounded-full border border-border bg-panel/85 text-[16px] text-foreground shadow-sm transition hover:bg-panel-elevated";
    headerActionButtonClass: str = "inline-flex h-10 items-center justify-center rounded-full border border-border bg-panel/85 px-4 text-[13px] font-medium text-foreground transition hover:bg-panel-elevated";
    headerGhostButtonClass: str = "inline-flex h-9 w-9 items-center justify-center rounded-full border border-border bg-panel/85 text-[16px] text-foreground shadow-sm transition hover:bg-panel-elevated";
    settingsPanelClass: str = "col-span-2 w-[220px] justify-self-center rounded-[1.2rem] border border-border bg-panel/92 p-4 shadow-[var(--shadow-glow)]";
    leftRailClass: str = "flex shrink-0 flex-col gap-2 pt-1 " + ("w-[176px] items-end" if confirmingNewGhost else "w-[60px] items-center");
    modelRows: list[JsxElement] = model_option_rows(modelOptions);

    if not setupLoaded {
        return <div className={shellClass}>
            <div className="flex min-h-[calc(100vh-4rem)] items-center justify-center">
                <div className="rounded-[2rem] border border-border bg-panel/90 px-6 py-5 text-[15px] text-muted shadow-[var(--shadow-glow)]">
                    Loading RepoGhost...
                </div>
            </div>
        </div>;
    }

    if not setupComplete {
        return <div className={shellClass}>
            <div className="flex min-h-[calc(100vh-4rem)] items-center justify-center">
                <SetupShell
                    apiKey={userApiKey}
                    selectedModel={selectedModel}
                    modelOptions={modelOptions}
                    rememberSettings={rememberSettings}
                    loading={False}
                    error={error}
                    setApiKey={update_user_api_key}
                    setSelectedModel={update_selected_model}
                    setRememberSettings={update_remember_settings}
                    submitSetup={submit_setup}
                />
            </div>
        </div>;
    }

    return <div className={shellClass}>
        <div className="mx-auto flex min-h-[calc(100vh-32px)] w-full max-w-[1240px] flex-wrap items-start justify-center gap-5">
            <div className={leftRailClass}>
                {(
                    <button onClick={prompt_new_ghost} className={headerGhostButtonClass} title="Start a new ghost">
                        👻
                    </button>
                    if not confirmingNewGhost
                    else <button onClick={cancel_new_ghost} className={headerActionButtonClass}>
                        New Ghost
                    </button>
                )}

                {(
                    <div />
                    if not confirmingNewGhost
                    else <div className="w-[176px] rounded-[1.2rem] border border-danger/35 bg-danger/10 p-3.5 shadow-[var(--shadow-glow)]">
                        <div className="text-[13px] leading-5 text-foreground">This clears the current session.</div>
                        <div className="mt-3 flex flex-col gap-2">
                            <button onClick={confirm_new_ghost} className="inline-flex h-9 items-center justify-center rounded-full bg-danger px-4 text-[12px] font-semibold text-white transition hover:brightness-110">
                                Destroy Session
                            </button>
                            <button onClick={cancel_new_ghost} className={headerActionButtonClass}>
                                Cancel
                            </button>
                        </div>
                    </div>
                )}
            </div>

            <div className="min-w-0 w-[50vw] max-w-[720px] max-[930px]:w-full max-[930px]:max-w-[720px]">
                <WidgetShell
                    bundle={bundle}
                    runState={runState}
                    meetingText={meetingText}
                    contextFileName={contextFileName}
                    contextLoading={processingContext}
                    queryLoading={answeringQuery}
                    loading={shellLoading}
                    error={error}
                    activeWidgetTab={activeWidgetTab}
                    repoPath={repoPath}
                    ownership={ownershipData}
                    decisions={decisionsData}
                    statusMessage={statusMessage}
                    hasProcessedContext={hasProcessedContext}
                    followUpPrompt={followUpPrompt}
                    followUpHistory={followUpHistory}
                    setRepoPath={update_repo_path}
                    setMeetingText={update_meeting_text}
                    setContextFileName={update_context_file_name}
                    setActiveWidgetTab={update_active_widget_tab}
                    setFollowUpPrompt={update_follow_up_prompt}
                    processContext={process_context}
                    askAboutRun={ask_about_run}
                />
            </div>

            <div className="grid w-[240px] shrink-0 grid-cols-2 justify-items-center content-start gap-2 pt-1 max-[930px]:w-full max-[930px]:max-w-[720px] max-[930px]:pl-[60px]">
                <button onClick={toggle_theme} className={headerIconButtonClass + " justify-self-center"} title={("Switch to light mode" if themeMode == "dark" else "Switch to dark mode")}>
                    {("☀" if themeMode == "dark" else "☾")}
                </button>
                <button onClick={toggle_contrast} className={headerIconButtonClass + " justify-self-center"} title={("Enable high contrast" if contrastMode == "standard" else "Use standard contrast")}>
                    {("◐" if contrastMode == "standard" else "◎")}
                </button>
                <button onClick={toggle_settings_editor} className={headerActionButtonClass + " col-span-2 w-[220px] justify-self-center"}>
                    Change API Key
                </button>
                <select
                    value={selectedModel}
                    onChange={lambda e: Any -> None { update_selected_model(e.target.value); }}
                    className="col-span-2 h-10 w-[220px] justify-self-center rounded-full border border-border bg-panel/85 px-4 text-[13px] font-medium text-foreground outline-none transition focus:border-accent"
                >
                    {modelRows}
                </select>

                {(
                    <div />
                    if not settingsEditorOpen
                    else <div className={settingsPanelClass}>
                        <div className="space-y-4">
                            <div>
                                <div className="mb-2 text-[11px] font-semibold uppercase tracking-[0.12em] text-muted">API Key</div>
                                <input
                                    type="password"
                                    value={userApiKey}
                                    onChange={lambda e: Any -> None { update_user_api_key(e.target.value); }}
                                    placeholder="sk-..."
                                    className="w-full rounded-2xl border border-border bg-panel-soft px-4 py-3 text-[12px] text-foreground outline-none placeholder:text-muted focus:border-accent transition-colors"
                                />
                            </div>
                            <label className="flex items-start gap-3 rounded-2xl border border-border bg-panel-soft px-4 py-3 text-[12px] text-foreground">
                                <input
                                    type="checkbox"
                                    checked={rememberSettings}
                                    onChange={lambda e: Any -> None { update_remember_settings(e.target.checked); }}
                                    className="mt-0.5 h-4 w-4"
                                />
                                <span>Remember API key and model on this device</span>
                            </label>
                            <div className="flex flex-col gap-2">
                                <button onClick={save_api_settings} className={headerActionButtonClass}>Save</button>
                                <button onClick={clear_api_settings} className={headerActionButtonClass}>Clear Key</button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </div>
    </div>;
}
