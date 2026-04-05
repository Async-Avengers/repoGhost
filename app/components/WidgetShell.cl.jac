import from typing { Any }

def tab_class(tab: str, current: str) -> str {
    if tab == current {
        return "flex-1 border-b-2 border-accent px-2.5 py-2.5 text-[14px] font-semibold text-foreground transition-colors";
    }
    return "flex-1 border-b-2 border-transparent px-2.5 py-2.5 text-[14px] text-muted transition-colors hover:text-foreground";
}

def ends_with(text: str, suffix: str) -> bool {
    if not text or not suffix {
        return False;
    }
    segments: list[str] = text.split(suffix);
    return len(segments) > 1 and segments[len(segments) - 1] == "";
}

def safe_text(value: Any) -> str {
    if value is None {
        return "";
    }
    return str(value);
}

def file_ext_label(path: str) -> str {
    if not path {
        return "file";
    }
    lower: str = path.lower();
    if ends_with(lower, ".py") or ends_with(lower, ".pyi") { return "py"; }
    if ends_with(lower, ".tsx") { return "tsx"; }
    if ends_with(lower, ".jsx") { return "jsx"; }
    if ends_with(lower, ".ts") { return "ts"; }
    if ends_with(lower, ".js") or ends_with(lower, ".mjs") or ends_with(lower, ".cjs") { return "js"; }
    if ends_with(lower, ".sv.jac") { return "sv.jac"; }
    if ends_with(lower, ".cl.jac") { return "cl.jac"; }
    if ends_with(lower, ".jac") { return "jac"; }
    if ends_with(lower, ".go") { return "go"; }
    if ends_with(lower, ".rs") { return "rs"; }
    if ends_with(lower, ".java") { return "java"; }
    if ends_with(lower, ".kt") or ends_with(lower, ".kts") { return "kt"; }
    if ends_with(lower, ".cs") { return "cs"; }
    if ends_with(lower, ".cpp") or ends_with(lower, ".cc") or ends_with(lower, ".cxx") { return "cpp"; }
    if ends_with(lower, ".c") { return "c"; }
    if ends_with(lower, ".rb") { return "rb"; }
    if ends_with(lower, ".php") { return "php"; }
    if ends_with(lower, ".swift") { return "swift"; }
    if ends_with(lower, ".dart") { return "dart"; }
    if ends_with(lower, ".vue") { return "vue"; }
    if ends_with(lower, ".svelte") { return "svelte"; }
    if ends_with(lower, ".html") or ends_with(lower, ".htm") { return "html"; }
    if ends_with(lower, ".css") or ends_with(lower, ".scss") or ends_with(lower, ".sass") { return "css"; }
    if ends_with(lower, ".json") { return "json"; }
    if ends_with(lower, ".toml") { return "toml"; }
    if ends_with(lower, ".yaml") or ends_with(lower, ".yml") { return "yaml"; }
    if ends_with(lower, ".md") or ends_with(lower, ".mdx") { return "md"; }
    return "file";
}

def file_ext_badge_class(path: str) -> str {
    lower: str = path.lower();
    base: str = "inline-flex shrink-0 items-center rounded-md px-2 py-1 text-[11px] font-semibold ";
    if ends_with(lower, ".py") or ends_with(lower, ".pyi") { return base + "bg-blue-500/20 text-blue-300"; }
    if ends_with(lower, ".tsx") or ends_with(lower, ".jsx") { return base + "bg-cyan-500/20 text-cyan-300"; }
    if ends_with(lower, ".ts") or ends_with(lower, ".js") or ends_with(lower, ".mjs") or ends_with(lower, ".cjs") { return base + "bg-yellow-500/20 text-yellow-300"; }
    if ends_with(lower, ".jac") { return base + "bg-accent/20 text-accent"; }
    if ends_with(lower, ".go") { return base + "bg-teal-500/20 text-teal-300"; }
    if ends_with(lower, ".rs") { return base + "bg-orange-500/20 text-orange-300"; }
    if ends_with(lower, ".java") or ends_with(lower, ".kt") or ends_with(lower, ".kts") { return base + "bg-red-500/20 text-red-300"; }
    if ends_with(lower, ".md") or ends_with(lower, ".mdx") { return base + "bg-slate-500/20 text-slate-300"; }
    return base + "bg-border text-muted";
}

def section_label(text: str) -> JsxElement {
    return <div className="text-[12px] font-semibold uppercase tracking-[0.14em] text-muted">{text}</div>;
}

def card_class() -> str {
    return "min-w-0 overflow-hidden rounded-[1.2rem] border border-border bg-panel-soft/90 p-3.5";
}

def invoke_callback(fn: Any, value: Any) -> None {
    fn.call(None, value);
}

def invoke_noarg_callback(fn: Any) -> None {
    fn.call(None);
}

async def invoke_async_callback(fn: Any) -> None {
    await fn.call(None);
}

def status_badge_label(run_state: Any, loading: bool) -> str {
    if loading {
        return "Running";
    }
    if not run_state or not run_state.execution_mode {
        return "Idle";
    }
    if run_state.execution_mode == "llm" {
        return "LLM";
    }
    if run_state.execution_mode == "hybrid" {
        return "Hybrid";
    }
    return "Fallback";
}

def status_badge_class(run_state: Any, loading: bool) -> str {
    base: str = "inline-flex items-center rounded-full border px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.08em] ";
    if loading {
        return base + "border-accent/40 bg-accent/10 text-accent";
    }
    if not run_state or not run_state.execution_mode {
        return base + "border-border bg-panel-soft text-muted";
    }
    if run_state.execution_mode == "llm" {
        return base + "border-emerald-500/40 bg-emerald-500/10 text-emerald-300";
    }
    if run_state.execution_mode == "hybrid" {
        return base + "border-sky-500/40 bg-sky-500/10 text-sky-300";
    }
    return base + "border-amber-500/40 bg-amber-500/10 text-amber-300";
}

def history_bubble_class(role: str) -> str {
    if role == "user" {
        return "ml-auto max-w-[92%] break-words rounded-[1.2rem] border border-accent/30 bg-accent/10 px-4 py-3 text-[14px] text-foreground";
    }
    return "max-w-[92%] break-words rounded-[1.2rem] border border-border bg-panel-soft px-4 py-3 text-[14px] text-foreground";
}

def:pub WidgetShell(
    bundle: Any = None,
    runState: Any = None,
    meetingText: str = "",
    contextFileName: str = "",
    contextLoading: bool = False,
    queryLoading: bool = False,
    loading: bool = False,
    error: str = "",
    activeWidgetTab: str = "context",
    repoPath: str = "",
    ownership: list[Any] = [],
    decisions: list[Any] = [],
    statusMessage: str = "",
    hasProcessedContext: bool = False,
    followUpPrompt: str = "",
    followUpHistory: list[dict[str, str]] = [],
    setRepoPath: Any = None,
    setMeetingText: Any = None,
    setContextFileName: Any = None,
    setActiveWidgetTab: Any = None,
    setFollowUpPrompt: Any = None,
    processContext: Any = None,
    askAboutRun: Any = None
) -> JsxElement {
    files: list[Any] = [];
    blockers: list[Any] = [];
    tasks: list[Any] = [];
    tickets: list[Any] = [];
    transcriptSummary: str = "";
    runSummary: str = statusMessage;
    projectName: str = "RepoGhost";
    projectType: str = "";
    nextSteps: list[str] = [];

    if bundle {
        files = bundle.relevant_files or [];
        blockers = bundle.blockers or [];
        tasks = bundle.tasks or [];
        tickets = bundle.tickets or [];
        if bundle.meeting_summary and bundle.meeting_summary.summary {
            transcriptSummary = bundle.meeting_summary.summary;
        }
        if bundle.repo_summary {
            if bundle.repo_summary.project_name {
                projectName = bundle.repo_summary.project_name;
            }
            if bundle.repo_summary.project_type {
                projectType = bundle.repo_summary.project_type;
            }
        }
        if bundle.handoff and bundle.handoff.next_actions {
            nextSteps = bundle.handoff.next_actions;
        } elif bundle.standup and bundle.standup.next {
            nextSteps = bundle.standup.next;
        }
    }
    if runState and runState.summary {
        runSummary = runState.summary;
    }

    def open_context_tab() -> None {
        if setActiveWidgetTab {
            invoke_callback(setActiveWidgetTab, "context");
        }
    }

    def open_tasks_tab() -> None {
        if setActiveWidgetTab {
            invoke_callback(setActiveWidgetTab, "tasks");
        }
    }

    def open_summary_tab() -> None {
        if setActiveWidgetTab {
            invoke_callback(setActiveWidgetTab, "summary");
        }
    }

    async def process_current_context() -> None {
        if processContext {
            await invoke_async_callback(processContext);
        }
    }

    async def ask_current_run() -> None {
        if askAboutRun {
            await invoke_async_callback(askAboutRun);
        }
    }

    async def handle_transcript_upload(e: Any) -> None {
        file_list: Any = e.target.files;
        if file_list is None or file_list.length == 0 {
            return;
        }
        file: Any = file_list[0];
        file_text: Any = await file.text();
        if setMeetingText {
            invoke_callback(setMeetingText, str(file_text));
        }
        if setContextFileName {
            invoke_callback(setContextFileName, str(file.name));
        }
    }

    fileRows: list[JsxElement] = [];
    for item in files {
        itemPath: str = safe_text(item.path);
        itemKey: str = itemPath + "::" + str(len(fileRows));
        fileRows.append(
            <div key={itemKey} className="flex min-w-0 items-center gap-3 rounded-xl border border-border/70 bg-panel px-3 py-2 overflow-hidden">
                <span className={file_ext_badge_class(itemPath)}>{file_ext_label(itemPath)}</span>
                <span className="truncate text-[14px] text-foreground" title={itemPath}>{itemPath}</span>
            </div>
        );
        if len(fileRows) >= 4 {
            break;
        }
    }

    ownershipRows: list[JsxElement] = [];
    for item in ownership {
        ownerKey: str = safe_text(item.area) + "::" + safe_text(item.owner) + "::" + str(len(ownershipRows));
        ownershipRows.append(
            <div key={ownerKey} className="rounded-xl border border-border/70 bg-panel px-3 py-3">
                <div className="text-[14px] font-semibold text-foreground">{safe_text(item.area)}</div>
                <div className="mt-1 text-[13px] text-muted">{safe_text(item.owner)}</div>
            </div>
        );
        if len(ownershipRows) >= 3 {
            break;
        }
    }

    taskCards: list[JsxElement] = [];
    for item in tasks {
        fileTags: list[JsxElement] = [];
        likelyFiles: list[str] = item.likely_files or [];
        for filePath in likelyFiles {
            fileKey: str = safe_text(item.title) + "::file::" + str(len(fileTags));
            fileTags.append(
                <span key={fileKey} className="max-w-full truncate rounded-full border border-border px-2 py-0.5 text-[11px] text-muted">
                    {filePath}
                </span>
            );
            if len(fileTags) >= 3 {
                break;
            }
        }
        taskCards.append(
            <div key={safe_text(item.title) + "::" + str(len(taskCards))} className="min-w-0 overflow-hidden rounded-[1.3rem] border border-border bg-panel-soft/90 p-4">
                <div className="break-words text-[15px] font-semibold text-foreground">{safe_text(item.title)}</div>
                <div className="mt-2 break-words text-[14px] leading-6 text-muted">{safe_text(item.summary)}</div>
                <div className="mt-3 flex flex-wrap gap-2">{fileTags}</div>
            </div>
        );
        if len(taskCards) >= 3 {
            break;
        }
    }

    ticketRows: list[JsxElement] = [];
    for item in tickets {
        ticketRows.append(
            <div key={safe_text(item.title) + "::" + str(len(ticketRows))} className="min-w-0 overflow-hidden rounded-xl border border-border/70 bg-panel px-3 py-3">
                <div className="break-words text-[14px] font-semibold text-foreground">{safe_text(item.title)}</div>
                <div className="mt-1 break-words text-[13px] text-muted">{safe_text(item.summary)}</div>
            </div>
        );
        if len(ticketRows) >= 2 {
            break;
        }
    }

    decisionRows: list[JsxElement] = [];
    for item in decisions {
        decisionRows.append(
            <div key={safe_text(item.title) + "::" + str(len(decisionRows))} className="min-w-0 overflow-hidden rounded-xl border border-border/70 bg-panel px-3 py-3">
                <div className="break-words text-[14px] font-semibold text-foreground">{safe_text(item.title)}</div>
                <div className="mt-1 break-words text-[13px] text-muted">{safe_text(item.detail)}</div>
            </div>
        );
        if len(decisionRows) >= 3 {
            break;
        }
    }

    blockerRows: list[JsxElement] = [];
    for item in blockers {
        blockerRows.append(
            <div key={safe_text(item.title) + "::" + str(len(blockerRows))} className="min-w-0 overflow-hidden rounded-xl border border-danger/20 bg-danger/5 px-3 py-3">
                <div className="break-words text-[14px] font-semibold text-foreground">{safe_text(item.title)}</div>
                <div className="mt-1 break-words text-[13px] text-muted">{safe_text(item.detail)}</div>
            </div>
        );
        if len(blockerRows) >= 2 {
            break;
        }
    }

    nextStepRows: list[JsxElement] = [];
    for item in nextSteps {
        nextStepRows.append(
            <div key={item + "::" + str(len(nextStepRows))} className="min-w-0 break-words rounded-xl border border-border/70 bg-panel px-3 py-3 text-[14px] text-foreground">
                {item}
            </div>
        );
        if len(nextStepRows) >= 3 {
            break;
        }
    }

    historyWindow: list[dict[str, str]] = followUpHistory;
    if len(historyWindow) > 4 {
        historyWindow = historyWindow[len(historyWindow) - 4:];
    }

    queryRows: list[JsxElement] = [];
    for item in historyWindow {
        role: str = item["role"];
        queryRows.append(
            <div key={role + "::" + str(len(queryRows))} className="flex">
                <div className={history_bubble_class(role)}>{item["content"]}</div>
            </div>
        );
    }

    errorBanner: JsxElement = <div />;
    if error {
        errorBanner = <div className="mx-5 mt-4 rounded-2xl border border-danger/40 bg-danger/10 px-4 py-3 text-[14px] text-foreground">
            {error}
        </div>;
    }

    processedContextBody: JsxElement = <div className="space-y-3 min-w-0">
        <div className={card_class() + " space-y-3"}>
            <div className="flex items-center justify-between gap-3">
                {section_label("Grounded Files")}
                <span className="text-[12px] text-muted">{str(len(files)) + " files"}</span>
            </div>
            <div className="space-y-2 min-w-0">{fileRows}</div>
        </div>
        <div className={card_class() + " space-y-3"}>
            {section_label("Ownership Map")}
            <div className="grid grid-cols-1 gap-3">{ownershipRows}</div>
        </div>
    </div>;

    emptyContextBody: JsxElement = <div className={card_class()}>
        <div className="text-[14px] font-semibold text-foreground">Add a repo and transcript, then process context.</div>
    </div>;

    contextTail: JsxElement = emptyContextBody;
    if hasProcessedContext {
        contextTail = processedContextBody;
    }

    contextContent: JsxElement = <div className="space-y-4">
        <div className={card_class() + " space-y-4"}>
            <div className="flex items-center justify-between gap-3">
                {section_label("Context Input")}
                <span className={status_badge_class(runState, loading)}>{status_badge_label(runState, loading)}</span>
            </div>
            <div>
                <div className="mb-2 text-[14px] font-semibold text-foreground">Repository Path</div>
                <input
                    type="text"
                    value={repoPath}
                    onChange={lambda e: Any -> None { if setRepoPath { invoke_callback(setRepoPath, e.target.value); } }}
                    placeholder="C:/path/to/repo"
                    className="w-full rounded-2xl border border-border bg-panel px-4 py-3 text-[15px] text-foreground outline-none placeholder:text-muted focus:border-accent transition-colors"
                />
            </div>
            <div>
                <div className="mb-2 text-[14px] font-semibold text-foreground">Meeting / Transcript</div>
                <textarea
                    value={meetingText}
                    onChange={lambda e: Any -> None {
                        if setContextFileName { invoke_callback(setContextFileName, ""); }
                        if setMeetingText { invoke_callback(setMeetingText, e.target.value); }
                    }}
                    placeholder="Paste transcript notes, decisions, or discussion highlights..."
                    rows={5}
                    className="w-full rounded-2xl border border-border bg-panel px-4 py-3 text-[15px] text-foreground outline-none placeholder:text-muted focus:border-accent transition-colors resize-none"
                />
            </div>
            <div>
                <div className="mb-2 text-[14px] font-semibold text-foreground">Text File Upload</div>
                <input
                    type="file"
                    accept=".txt,.md,.mdx,.log,text/plain,text/markdown"
                    onChange={handle_transcript_upload}
                    className="w-full rounded-2xl border border-border bg-panel px-4 py-3 text-[14px] text-foreground"
                />
                <div className="mt-2 text-[12px] text-muted">
                    {contextFileName if contextFileName else "Upload fills the transcript field."}
                </div>
            </div>
            <button
                onClick={process_current_context}
                disabled={contextLoading}
                className="inline-flex items-center justify-center rounded-2xl bg-accent px-5 py-3 text-[15px] font-semibold text-background transition hover:brightness-110 disabled:cursor-not-allowed disabled:opacity-60"
            >
                {("Processing Context..." if contextLoading else "Process Context")}
            </button>
        </div>
        {contextTail}
    </div>;

    processedTasksBody: JsxElement = <div className="space-y-3 min-w-0">
        <div className={card_class() + " space-y-3"}>
            {section_label("Execution Tasks")}
            <div className="grid grid-cols-1 gap-3 min-w-0">{taskCards}</div>
        </div>
        <div className={card_class() + " space-y-3"}>
            {section_label("Ticket Preview")}
            <div className="grid grid-cols-1 gap-3 min-w-0">{ticketRows}</div>
        </div>
    </div>;

    emptyTasksBody: JsxElement = <div className={card_class()}>
        <div className="text-[14px] font-semibold text-foreground">Process context to generate tasks.</div>
    </div>;

    tasksContent: JsxElement = emptyTasksBody;
    if hasProcessedContext {
        tasksContent = processedTasksBody;
    }

    processedSummaryBody: JsxElement = <div className="space-y-3 min-w-0">
        <div className={card_class()}>
            {section_label("Project / Run Summary")}
            <div className="mt-3 text-[15px] font-semibold text-foreground">{projectName}</div>
            <div className="mt-2 break-words text-[14px] leading-6 text-muted">{runSummary}</div>
            {(<div /> if not projectType else <div className="mt-3 inline-flex rounded-full border border-accent/30 bg-accent/10 px-3 py-1 text-[12px] font-medium text-accent">{projectType}</div>)}
        </div>
        <div className={card_class()}>
            {section_label("Transcript Summary")}
            <div className="mt-3 break-words text-[14px] leading-6 text-foreground">
                {transcriptSummary if transcriptSummary else "Transcript understanding will appear here after the run completes."}
            </div>
        </div>
        <div className={card_class() + " space-y-3"}>
            {section_label("Decisions")}
            <div className="grid grid-cols-1 gap-3">{decisionRows}</div>
        </div>
        <div className={card_class() + " space-y-3"}>
            {section_label("Current Blockers")}
            <div className="grid grid-cols-1 gap-3">{blockerRows}</div>
        </div>
        <div className={card_class() + " space-y-3"}>
            {section_label("Next Steps")}
            <div className="grid grid-cols-1 gap-3">{nextStepRows}</div>
        </div>
        <div className={card_class() + " space-y-3"}>
            {section_label("Ask About This Run")}
            <textarea
                value={followUpPrompt}
                onChange={lambda e: Any -> None { if setFollowUpPrompt { invoke_callback(setFollowUpPrompt, e.target.value); } }}
                placeholder="Ask about this run."
                rows={3}
                className="w-full rounded-2xl border border-border bg-panel px-4 py-3 text-[15px] text-foreground outline-none placeholder:text-muted focus:border-accent transition-colors resize-none"
            />
            <button
                onClick={ask_current_run}
                disabled={queryLoading}
                className="inline-flex items-center justify-center rounded-2xl bg-accent px-5 py-3 text-[15px] font-semibold text-background transition hover:brightness-110 disabled:cursor-not-allowed disabled:opacity-60"
            >
                {("Thinking..." if queryLoading else "Ask")}
            </button>
            <div className="space-y-3 min-w-0">{queryRows}</div>
        </div>
    </div>;

    emptySummaryBody: JsxElement = <div className={card_class()}>
        <div className="text-[14px] font-semibold text-foreground">Process context to unlock the summary.</div>
    </div>;

    summaryContent: JsxElement = emptySummaryBody;
    if hasProcessedContext {
        summaryContent = processedSummaryBody;
    }

    tabContent: JsxElement = contextContent;
    if activeWidgetTab == "tasks" {
        tabContent = tasksContent;
    } elif activeWidgetTab == "summary" {
        tabContent = summaryContent;
    }

    subtitle: str = "Repo sidecar";

    return <div className="repoghost-widget flex h-[calc(100vh-32px)] w-full min-w-0 max-w-none flex-col overflow-hidden rounded-[1.7rem] border border-border bg-panel/95 shadow-[var(--shadow-glow)]">
        <div className="border-b border-border px-4 py-3.5">
            <div className="min-w-0">
                <div className="flex items-center gap-3">
                    <span className="text-[22px]">👻</span>
                    <div className="min-w-0">
                        <div className="text-[18px] font-semibold tracking-tight text-foreground">RepoGhost</div>
                        <div className="truncate text-[12px] text-muted">{subtitle}</div>
                    </div>
                </div>
            </div>
        </div>

        {errorBanner}

        <div className="flex border-b border-border">
            <button onClick={open_context_tab} className={tab_class("context", activeWidgetTab)}>Context</button>
            <button onClick={open_tasks_tab} className={tab_class("tasks", activeWidgetTab)}>Tasks</button>
            <button onClick={open_summary_tab} className={tab_class("summary", activeWidgetTab)}>Summary</button>
        </div>

        <div className="repoghost-scroll flex-1 min-w-0 overflow-y-auto overflow-x-hidden px-5 py-4">
            {tabContent}
        </div>
    </div>;
}
