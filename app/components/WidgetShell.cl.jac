import from typing { Any }

def tab_class(tab: str, current: str) -> str {
    if tab == current {
        return "flex-1 py-2 text-sm font-medium text-foreground border-b-2 border-accent transition-colors";
    }
    return "flex-1 py-2 text-sm text-muted border-b-2 border-transparent hover:text-foreground transition-colors";
}

def file_basename(path: str) -> str {
    normalized: str = path.replace("\\", "/");
    parts: list[str] = normalized.split("/");
    return parts[-1];
}

def file_ext_label(path: str) -> str {
    lower: str = path.lower();
    if lower.endswith(".py") {
        return "py";
    }
    if lower.endswith(".jsx") {
        return "jsx";
    }
    if lower.endswith(".tsx") {
        return "tsx";
    }
    if lower.endswith(".ts") {
        return "ts";
    }
    if lower.endswith(".js") {
        return "js";
    }
    if lower.endswith(".jac") {
        return "jac";
    }
    dot_parts: list[str] = path.split(".");
    if len(dot_parts) > 1 {
        ext: str = dot_parts[-1];
        if len(ext) <= 4 {
            return ext;
        }
    }
    return "file";
}

def file_ext_badge_class(path: str) -> str {
    lower: str = path.lower();
    if lower.endswith(".py") {
        return "rounded px-1.5 py-0.5 text-[10px] font-medium bg-blue-500/20 text-blue-300";
    }
    if lower.endswith(".jsx") or lower.endswith(".tsx") {
        return "rounded px-1.5 py-0.5 text-[10px] font-medium bg-cyan-500/20 text-cyan-300";
    }
    if lower.endswith(".js") or lower.endswith(".ts") {
        return "rounded px-1.5 py-0.5 text-[10px] font-medium bg-yellow-500/20 text-yellow-300";
    }
    if lower.endswith(".jac") {
        return "rounded px-1.5 py-0.5 text-[10px] font-medium bg-accent/20 text-accent";
    }
    return "rounded px-1.5 py-0.5 text-[10px] font-medium bg-border text-muted";
}

def avatar_color_class(idx: int) -> str {
    if idx == 0 {
        return "flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-purple-500/30 text-xs font-semibold text-purple-300";
    }
    if idx == 1 {
        return "flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-blue-500/30 text-xs font-semibold text-blue-300";
    }
    return "flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-green-500/30 text-xs font-semibold text-green-300";
}

def section_label(text: str) -> JsxElement {
    return <div className="mb-2 text-xs font-semibold text-muted uppercase tracking-[0.12em]">{text}</div>;
}

def invoke_callback(fn: Any, value: Any) -> None {
    fn.call(None, value);
}

async def invoke_async_callback(fn: Any, value: Any) -> None {
    await fn.call(None, value);
}

def mark_used(value: Any) -> None {
    if value {
        return;
    }
}

def:pub WidgetShell(
    bundle: Any = None,
    mode: str = "feature_plan",
    draftPrompt: str = "",
    loading: bool = False,
    error: str = "",
    lastRunLabel: str = "Ready",
    activeWidgetTab: str = "context",
    repoPath: str = "",
    ownership: list[Any] = [],
    standup: Any = None,
    decisions: list[Any] = [],
    graphNodes: list[Any] = [],
    actionPlanPhases: list[str] = [],
    ticketTitles: list[str] = [],
    handoffActions: list[str] = [],
    graphFocusPaths: list[str] = [],
    setDraftPrompt: Any = None,
    setRepoPath: Any = None,
    setActiveWidgetTab: Any = None,
    submit: Any = None
) -> JsxElement {
    onSetRepo = setRepoPath;
    onSetTab = setActiveWidgetTab;
    onSubmit = submit;

    mark_used(setDraftPrompt);
    mark_used(mode);
    mark_used(lastRunLabel);
    mark_used(graphNodes);
    mark_used(actionPlanPhases);
    mark_used(ticketTitles);
    mark_used(handoffActions);
    mark_used(graphFocusPaths);

    files: list[Any] = [];
    blockers: list[Any] = [];
    tasks: list[Any] = [];
    projectName: str = "";
    if bundle {
        files = bundle.relevant_files or [];
        blockers = bundle.blockers or [];
        tasks = bundle.tasks or [];
        if bundle.repo_summary {
            if bundle.repo_summary.project_name {
                projectName = bundle.repo_summary.project_name;
            }
        }
    }

    todoItems: list[str] = [];
    inProgressItems: list[str] = [];
    standupBlockers: list[str] = [];
    if standup {
        todoItems = standup.next or [];
        inProgressItems = standup.done or [];
        standupBlockers = standup.blockers or [];
    }

    # --- Tab click handlers ---

    def clickContextTab() -> None {
        if onSetTab {
            invoke_callback(onSetTab, "context");
        }
    }

    def clickTasksTab() -> None {
        if onSetTab {
            invoke_callback(onSetTab, "tasks");
        }
    }

    def clickSummaryTab() -> None {
        if onSetTab {
            invoke_callback(onSetTab, "summary");
        }
    }

    # --- Workflow action handlers ---

    async def runAgents() -> None {
        if onSubmit {
            await invoke_async_callback(onSubmit, draftPrompt);
        }
    }

    async def rescanRepo() -> None {
        if onSubmit {
            await invoke_async_callback(onSubmit, draftPrompt);
        }
    }

    async def generateTickets() -> None {
        if onSubmit {
            await invoke_async_callback(onSubmit, "Generate tickets from the current repo and meeting context.");
        }
    }

    async def updateDocs() -> None {
        if onSubmit {
            await invoke_async_callback(onSubmit, "Sync documentation and generate a handoff note.");
        }
    }

    async def codeSearch() -> None {
        if onSubmit {
            await invoke_async_callback(onSubmit, "Search for relevant code files and summarize their roles.");
        }
    }

    async def copyReport() -> None {
        if onSubmit {
            await invoke_async_callback(onSubmit, "Generate a summary report of this session.");
        }
    }

    def viewPlans() -> None {
        if onSetTab {
            invoke_callback(onSetTab, "tasks");
        }
    }

    # --- Build Context tab ---

    fileRows: list[JsxElement] = [];
    for item in files {
        if len(fileRows) >= 3 {
            break;
        }
        basename: str = file_basename(item.path);
        extLabel: str = file_ext_label(item.path);
        extClass: str = file_ext_badge_class(item.path);
        fileRows.append(
            <div key={item.path} className="flex items-center gap-2 py-1.5">
                <span className={extClass}>{extLabel}</span>
                <span className="text-sm text-foreground truncate">{basename}</span>
            </div>
        );
    }
    if len(fileRows) == 0 {
        fileRows.append(
            <div key="no-files" className="py-1.5 text-sm text-muted">No files scanned yet.</div>
        );
    }

    ownerRows: list[JsxElement] = [];
    ownerIdx: int = 0;
    for item in ownership {
        if ownerIdx >= 3 {
            break;
        }
        avatarClass: str = avatar_color_class(ownerIdx);
        ownerName: str = str(item.owner);
        ownerArea: str = str(item.area);
        initial: str = ownerName[:1].upper() if ownerName else "?";
        ownerLabel: str = ownerArea + ": " + ownerName;
        ownerRows.append(
            <div key={ownerArea} className="flex items-center gap-2 py-1.5">
                <div className={avatarClass}>{initial}</div>
                <span className="text-sm text-foreground">{ownerLabel}</span>
            </div>
        );
        ownerIdx = ownerIdx + 1;
    }
    if len(ownerRows) == 0 {
        ownerRows.append(
            <div key="no-owners" className="py-1.5 text-sm text-muted">No ownership data yet.</div>
        );
    }

    projectPlaceholder: str = projectName if projectName else "Enter repo path...";

    contextContent: JsxElement = <div className="space-y-4">
        <div>
            {section_label("Identified Project:")}
            <input
                type="text"
                value={repoPath}
                onChange={lambda e: Any -> None { if onSetRepo { invoke_callback(onSetRepo, e.target.value); } }}
                placeholder={projectPlaceholder}
                className="w-full rounded-lg border border-border bg-panel-soft px-3 py-2 text-sm text-foreground outline-none placeholder:text-muted focus:border-accent transition-colors"
            />
        </div>
        <div>
            {section_label("Active Files:")}
            <div className="space-y-0.5">{fileRows}</div>
        </div>
        <div>
            {section_label("Ownership Map:")}
            <div className="space-y-0.5">{ownerRows}</div>
        </div>
    </div>;

    # --- Build Tasks tab ---

    todoRows: list[JsxElement] = [];
    for item in todoItems {
        if len(todoRows) >= 3 {
            break;
        }
        todoRows.append(
            <div key={item} className="flex items-start gap-2 py-1">
                <span className="mt-0.5 text-success text-sm">✓</span>
                <span className="text-sm text-foreground">{item}</span>
            </div>
        );
    }
    if len(todoRows) == 0 {
        todoRows.append(
            <div key="no-todo" className="py-1 text-sm text-muted">No to-do items yet.</div>
        );
    }

    inProgressRows: list[JsxElement] = [];
    for item in tasks {
        if len(inProgressRows) >= 3 {
            break;
        }
        inProgressRows.append(
            <div key={item.title} className="flex items-start gap-2 py-1">
                <span className="mt-0.5 text-success text-sm">✓</span>
                <span className="text-sm text-foreground">{item.title}</span>
            </div>
        );
    }
    if len(inProgressRows) == 0 {
        inProgressRows.append(
            <div key="no-progress" className="py-1 text-sm text-muted">No tasks in progress yet.</div>
        );
    }

    blockerRows: list[JsxElement] = [];
    blockerSource: list[str] = standupBlockers;
    if len(blockerSource) == 0 {
        for b in blockers {
            blockerSource.append(b.title);
        }
    }
    for item in blockerSource {
        if len(blockerRows) >= 3 {
            break;
        }
        blockerRows.append(
            <div key={item} className="flex items-start gap-2 py-1">
                <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-danger" />
                <span className="text-sm text-foreground">{item}</span>
            </div>
        );
    }
    if len(blockerRows) == 0 {
        blockerRows.append(
            <div key="no-blockers" className="py-1 text-sm text-muted">No blockers surfaced yet.</div>
        );
    }

    actionBtnClass: str = "rounded-lg border border-border bg-panel-soft px-3 py-2 text-xs font-medium text-foreground hover:bg-border transition-colors disabled:opacity-50 disabled:cursor-not-allowed";

    tasksContent: JsxElement = <div className="space-y-4">
        <div className="text-sm font-semibold text-foreground">Task Breakdown</div>
        <div>
            {section_label("To-Do:")}
            <div className="space-y-0.5">{todoRows}</div>
        </div>
        <div>
            {section_label("In Progress:")}
            <div className="space-y-0.5">{inProgressRows}</div>
        </div>
        <div>
            {section_label("Blockers:")}
            <div className="space-y-0.5">{blockerRows}</div>
        </div>
        <div>
            {section_label("Next Actions:")}
            <div className="space-y-2">
                <div className="flex gap-2">
                    <button onClick={generateTickets} disabled={loading} className={actionBtnClass}>Generate Tickets</button>
                    <button onClick={updateDocs} disabled={loading} className={actionBtnClass}>Update Docs</button>
                </div>
                <button onClick={codeSearch} disabled={loading} className={"w-full " + actionBtnClass}>Code Search</button>
            </div>
        </div>
    </div>;

    # --- Build Summary tab ---

    changedRows: list[JsxElement] = [];
    for item in decisions {
        if len(changedRows) >= 3 {
            break;
        }
        changedRows.append(
            <div key={item.title} className="flex items-start gap-2 py-1">
                <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-success" />
                <span className="text-sm text-foreground">{item.title}</span>
            </div>
        );
    }
    if len(changedRows) == 0 {
        changedRows.append(
            <div key="no-changes" className="py-1 text-sm text-muted">No decisions recorded yet.</div>
        );
    }

    nextStepRows: list[JsxElement] = [];
    for item in todoItems {
        if len(nextStepRows) >= 3 {
            break;
        }
        nextStepRows.append(
            <div key={item} className="flex items-start gap-2 py-1">
                <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-success" />
                <span className="text-sm text-foreground">{item}</span>
            </div>
        );
    }
    if len(nextStepRows) == 0 {
        nextStepRows.append(
            <div key="no-next" className="py-1 text-sm text-muted">No next steps yet.</div>
        );
    }

    currentBlockerRows: list[JsxElement] = [];
    for item in blockers {
        if len(currentBlockerRows) >= 3 {
            break;
        }
        currentBlockerRows.append(
            <div key={item.title} className="flex items-start gap-2 py-1">
                <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-warning" />
                <span className="text-sm text-foreground">{item.title}</span>
            </div>
        );
    }
    if len(currentBlockerRows) == 0 {
        currentBlockerRows.append(
            <div key="no-current-blockers" className="py-1 text-sm text-muted">No blockers surfaced yet.</div>
        );
    }

    summaryContent: JsxElement = <div className="space-y-4">
        <div className="text-sm font-semibold text-foreground">Meeting Recap</div>
        <div>
            {section_label("Changes Made:")}
            <div className="space-y-0.5">{changedRows}</div>
        </div>
        <div>
            {section_label("Next Steps:")}
            <div className="space-y-0.5">{nextStepRows}</div>
        </div>
        <div>
            {section_label("Current Blockers:")}
            <div className="space-y-0.5">{currentBlockerRows}</div>
        </div>
    </div>;

    # --- Select active content and bottom bar ---

    tabContent: JsxElement = contextContent;
    if activeWidgetTab == "tasks" {
        tabContent = tasksContent;
    }
    if activeWidgetTab == "summary" {
        tabContent = summaryContent;
    }

    runBtnLabel: str = "Running..." if loading else "▲  Run Agents";
    outlineBtnClass: str = "flex-1 rounded-lg border border-border bg-transparent px-3 py-2 text-xs font-medium text-foreground hover:bg-panel-soft transition-colors";
    iconBtnClass: str = "rounded-lg p-2 text-muted hover:text-foreground transition-colors";

    contextBottom: JsxElement = <div className="flex items-center justify-between">
        <button onClick={rescanRepo} disabled={loading} className="flex items-center gap-1.5 rounded-lg border border-border bg-panel-soft px-3 py-2 text-xs font-medium text-foreground hover:bg-border transition-colors disabled:opacity-50 disabled:cursor-not-allowed">
            <span>👻</span>
            <span>Rescan Repo</span>
        </button>
        <div className="flex gap-1">
            <button className={iconBtnClass} title="Pin widget">📌</button>
            <button className={iconBtnClass} title="Filter">≡</button>
        </div>
    </div>;

    tasksBottom: JsxElement = <div className="flex items-center justify-between">
        <button onClick={runAgents} disabled={loading} className="flex items-center gap-1.5 rounded-lg bg-accent px-4 py-2 text-xs font-semibold text-background hover:brightness-110 transition disabled:opacity-50 disabled:cursor-not-allowed">
            <span>{runBtnLabel}</span>
        </button>
        <div className="flex gap-1">
            <button className={iconBtnClass} title="Suggestions">💡</button>
            <button className={iconBtnClass} title="Filter">≡</button>
        </div>
    </div>;

    summaryBottom: JsxElement = <div className="flex gap-2">
        <button onClick={viewPlans} className={outlineBtnClass}>View Plans</button>
        <button onClick={copyReport} disabled={loading} className={outlineBtnClass + " disabled:opacity-50"}>Copy Report</button>
    </div>;

    bottomBar: JsxElement = contextBottom;
    if activeWidgetTab == "tasks" {
        bottomBar = tasksBottom;
    }
    if activeWidgetTab == "summary" {
        bottomBar = summaryBottom;
    }

    # --- Error banner (shown above content if error) ---

    errorBanner: JsxElement = <div />;
    if error {
        errorBanner = <div className="mx-4 mt-3 rounded-lg border border-danger/40 bg-danger/10 px-3 py-2 text-xs text-foreground">
            {error}
        </div>;
    }

    return <div className="w-[380px] overflow-hidden rounded-2xl border border-border bg-[#0e1726] shadow-[var(--shadow-glow)] flex flex-col">

        <div className="flex items-center justify-between border-b border-border px-4 py-3">
            <div className="flex items-center gap-2">
                <span className="text-lg">👻</span>
                <span className="text-sm font-semibold text-foreground">RepoGhost</span>
            </div>
            <div className="flex items-center gap-1">
                <button className="rounded px-2 py-0.5 text-xs text-muted hover:text-foreground transition-colors">−</button>
                <button className="rounded px-2 py-0.5 text-xs text-muted hover:text-foreground transition-colors">×</button>
            </div>
        </div>

        <div className="flex border-b border-border">
            <button onClick={clickContextTab} className={tab_class("context", activeWidgetTab)}>Context</button>
            <button onClick={clickTasksTab} className={tab_class("tasks", activeWidgetTab)}>Tasks</button>
            <button onClick={clickSummaryTab} className={tab_class("summary", activeWidgetTab)}>Summary</button>
        </div>

        {errorBanner}

        <div className="flex-1 overflow-y-auto p-4">
            {tabContent}
        </div>

        <div className="border-t border-border px-4 py-3">
            {bottomBar}
        </div>

    </div>;
}
