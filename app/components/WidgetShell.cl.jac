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

def file_ext_label(p: str) -> str {
    if not p {
        return "file";
    }
    lower: str = p.lower();
    if lower.endswith(".py") or lower.endswith(".pyi") { return "py"; }
    if lower.endswith(".tsx") { return "tsx"; }
    if lower.endswith(".jsx") { return "jsx"; }
    if lower.endswith(".ts") { return "ts"; }
    if lower.endswith(".js") or lower.endswith(".mjs") or lower.endswith(".cjs") { return "js"; }
    if lower.endswith(".sv.jac") { return "sv.jac"; }
    if lower.endswith(".cl.jac") { return "cl.jac"; }
    if lower.endswith(".jac") { return "jac"; }
    if lower.endswith(".go") { return "go"; }
    if lower.endswith(".rs") { return "rs"; }
    if lower.endswith(".java") { return "java"; }
    if lower.endswith(".kt") or lower.endswith(".kts") { return "kt"; }
    if lower.endswith(".cs") { return "cs"; }
    if lower.endswith(".cpp") or lower.endswith(".cc") or lower.endswith(".cxx") { return "cpp"; }
    if lower.endswith(".c") { return "c"; }
    if lower.endswith(".rb") { return "rb"; }
    if lower.endswith(".php") { return "php"; }
    if lower.endswith(".swift") { return "swift"; }
    if lower.endswith(".dart") { return "dart"; }
    if lower.endswith(".vue") { return "vue"; }
    if lower.endswith(".svelte") { return "svelte"; }
    if lower.endswith(".html") or lower.endswith(".htm") { return "html"; }
    if lower.endswith(".css") { return "css"; }
    if lower.endswith(".scss") or lower.endswith(".sass") { return "scss"; }
    if lower.endswith(".json") { return "json"; }
    if lower.endswith(".toml") { return "toml"; }
    if lower.endswith(".yaml") or lower.endswith(".yml") { return "yaml"; }
    if lower.endswith(".md") or lower.endswith(".mdx") { return "md"; }
    if lower.endswith(".sh") or lower.endswith(".bash") { return "sh"; }
    dot_parts: list[str] = p.split(".");
    if len(dot_parts) > 1 {
        ext: str = dot_parts[-1];
        if len(ext) <= 5 {
            return ext;
        }
    }
    return "file";
}

def file_ext_badge_class(p: str) -> str {
    lower: str = p.lower();
    base: str = "rounded px-1.5 py-0.5 text-[10px] font-medium ";
    if lower.endswith(".py") or lower.endswith(".pyi") { return base + "bg-blue-500/20 text-blue-300"; }
    if lower.endswith(".tsx") or lower.endswith(".jsx") { return base + "bg-cyan-500/20 text-cyan-300"; }
    if lower.endswith(".ts") or lower.endswith(".js") or lower.endswith(".mjs") { return base + "bg-yellow-500/20 text-yellow-300"; }
    if lower.endswith(".jac") { return base + "bg-accent/20 text-accent"; }
    if lower.endswith(".go") { return base + "bg-teal-500/20 text-teal-300"; }
    if lower.endswith(".rs") { return base + "bg-orange-500/20 text-orange-300"; }
    if lower.endswith(".java") or lower.endswith(".kt") or lower.endswith(".kts") { return base + "bg-red-500/20 text-red-300"; }
    if lower.endswith(".cs") { return base + "bg-purple-500/20 text-purple-300"; }
    if lower.endswith(".cpp") or lower.endswith(".cc") or lower.endswith(".c") { return base + "bg-indigo-500/20 text-indigo-300"; }
    if lower.endswith(".rb") { return base + "bg-rose-500/20 text-rose-300"; }
    if lower.endswith(".php") { return base + "bg-violet-500/20 text-violet-300"; }
    if lower.endswith(".swift") { return base + "bg-orange-400/20 text-orange-200"; }
    if lower.endswith(".dart") { return base + "bg-sky-500/20 text-sky-300"; }
    if lower.endswith(".vue") { return base + "bg-emerald-500/20 text-emerald-300"; }
    if lower.endswith(".svelte") { return base + "bg-orange-600/20 text-orange-300"; }
    if lower.endswith(".html") or lower.endswith(".htm") { return base + "bg-amber-500/20 text-amber-300"; }
    if lower.endswith(".css") or lower.endswith(".scss") or lower.endswith(".sass") { return base + "bg-pink-500/20 text-pink-300"; }
    if lower.endswith(".json") or lower.endswith(".toml") or lower.endswith(".yaml") or lower.endswith(".yml") { return base + "bg-slate-500/20 text-slate-300"; }
    if lower.endswith(".md") or lower.endswith(".mdx") { return base + "bg-gray-500/20 text-gray-300"; }
    if lower.endswith(".sh") or lower.endswith(".bash") { return base + "bg-lime-500/20 text-lime-300"; }
    return base + "bg-border text-muted";
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
    projectType: str = "";
    if bundle {
        files = bundle.relevant_files or [];
        blockers = bundle.blockers or [];
        tasks = bundle.tasks or [];
        if bundle.repo_summary {
            if bundle.repo_summary.project_name {
                projectName = bundle.repo_summary.project_name;
            }
            if bundle.repo_summary.project_type {
                projectType = bundle.repo_summary.project_type;
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
            await invoke_async_callback(onSubmit, "Scan the repo and show relevant files, ownership map, and project context.");
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
        basename: str = file_basename(item.path);
        extLabel: str = file_ext_label(item.path);
        extClass: str = file_ext_badge_class(item.path);
        fileRows.append(
            <div key={item.path + "::" + str(len(fileRows))} className="flex items-center gap-2 py-1 min-w-0">
                <span className={extClass + " shrink-0"}>{extLabel}</span>
                <span className="text-xs text-foreground truncate" title={item.path}>{item.path}</span>
            </div>
        );
    }
    if len(fileRows) == 0 {
        fileRows.append(
            <div key="no-files" className="py-1.5 text-sm text-muted">No files scanned yet. Enter a repo path and click Rescan Repo.</div>
        );
    }
    fileCountLabel: str = str(len(files)) + " files";

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

    projectTypeBadge: JsxElement = <div />;
    if projectType {
        projectTypeBadge = <div className="mt-1.5 inline-flex items-center rounded-full border border-accent/30 bg-accent/10 px-2.5 py-0.5 text-[11px] font-medium text-accent">
            {projectType}
        </div>;
    }

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
            {projectTypeBadge}
        </div>
        <div>
            <div className="mb-2 flex items-center justify-between">
                {section_label("Active Files:")}
                <span className="text-[10px] text-muted">{fileCountLabel}</span>
            </div>
            <div className="max-h-52 overflow-y-auto space-y-0.5 pr-1">{fileRows}</div>
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
