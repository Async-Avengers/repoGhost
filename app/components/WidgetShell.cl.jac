import from typing { Any }

def widget_status_class(loading: bool, error: str) -> str {
    if error {
        return "mt-2 inline-flex rounded-full border border-danger/40 bg-danger/10 px-3 py-1 text-xs text-foreground";
    }
    if loading {
        return "mt-2 inline-flex rounded-full border border-warning/40 bg-warning/10 px-3 py-1 text-xs text-foreground";
    }
    return "mt-2 inline-flex rounded-full border border-success/30 bg-success/10 px-3 py-1 text-xs text-foreground";
}

def widget_run_label(loading: bool) -> str {
    if loading {
        return "Running";
    }
    return "Ready";
}

def widget_button_label(loading: bool) -> str {
    if loading {
        return "Running workflow...";
    }
    return "Run workflow";
}

def invoke_callback(fn: Any, value: Any) -> None {
    fn.call(None, value);
}

async def invoke_async_callback(fn: Any, value: Any) -> None {
    await fn.call(None, value);
}

def widget_error_panel(error: str) -> JsxElement {
    if error {
        return <div className="mt-4 rounded-[1.25rem] border border-danger/40 bg-danger/10 px-3 py-3 text-sm leading-6 text-foreground">
            RepoGhost could not finish the last run. Update the prompt or repo context and try again.
        </div>;
    }
    return <div />;
}


def:pub WidgetShell(
    bundle: Any = None,
    mode: str = "feature_plan",
    draftPrompt: str = "",
    loading: bool = False,
    error: str = "",
    lastRunLabel: str = "Ready",
    graphNodes: list[Any] = [],
    actionPlanPhases: list[str] = [],
    ticketTitles: list[str] = [],
    handoffActions: list[str] = [],
    graphFocusPaths: list[str] = [],
    setDraftPrompt: Any = None,
    submit: Any = None
) -> JsxElement {
    onDraft = setDraftPrompt;
    onSubmit = submit;

    files: list[Any] = [];
    blockers: list[Any] = [];
    nextStep = "Waiting for workflow context.";
    if bundle {
        files = bundle.relevant_files or [];
        blockers = bundle.blockers or [];
        nextStep = bundle.action_plan.next_task or nextStep;
    }

    fileCards = [];
    for item in files {
        if len(fileCards) >= 3 {
            break;
        }
        fileCards.append(
            <div key={item.path} className="rounded-xl border border-border bg-panel px-3 py-2">
                <div className="text-sm font-medium text-foreground">{item.path}</div>
                <div className="mt-1 text-xs text-muted">{item.rationale}</div>
            </div>
        );
    }
    if len(fileCards) == 0 {
        fileCards.append(<div key="no-files" className="rounded-xl border border-border bg-panel px-3 py-2 text-xs text-muted">No relevant files yet.</div>);
    }

    blockerCards = [];
    for item in blockers {
        if len(blockerCards) >= 3 {
            break;
        }
        blockerCards.append(
            <div key={item.title} className="rounded-xl border border-danger/30 bg-danger/10 px-3 py-2">
                <div className="text-sm font-medium text-foreground">{item.title}</div>
                <div className="mt-1 text-xs text-muted">{item.detail}</div>
            </div>
        );
    }
    if len(blockerCards) == 0 {
        blockerCards.append(<div key="no-blockers" className="rounded-xl border border-border bg-panel px-3 py-2 text-xs text-muted">No blockers surfaced yet.</div>);
    }

    phaseCards = [];
    for item in actionPlanPhases {
        if len(phaseCards) >= 4 {
            break;
        }
        phaseCards.append(<div key={item} className="rounded-xl border border-border bg-panel px-3 py-2 text-sm text-foreground">{item}</div>);
    }
    if len(phaseCards) == 0 {
        phaseCards.append(<div key="no-phases" className="rounded-xl border border-border bg-panel px-3 py-2 text-sm text-muted">No action plan phases yet.</div>);
    }

    focusPills = [];
    for item in graphFocusPaths {
        if len(focusPills) >= 3 {
            break;
        }
        focusPills.append(<div key={item} className="rounded-full border border-border bg-panel px-3 py-1 text-[11px] text-muted">{item}</div>);
    }
    if len(focusPills) == 0 {
        focusPills.append(<div key="no-focus" className="rounded-full border border-border bg-panel px-3 py-1 text-[11px] text-muted">No focus paths yet</div>);
    }

    handoffCards = [];
    for item in handoffActions {
        if len(handoffCards) >= 3 {
            break;
        }
        handoffCards.append(<div key={item} className="rounded-xl border border-border bg-panel px-3 py-2 text-sm text-foreground">{item}</div>);
    }
    if len(handoffCards) == 0 {
        handoffCards.append(<div key="no-handoff" className="rounded-xl border border-border bg-panel px-3 py-2 text-sm text-muted">No handoff actions yet.</div>);
    }

    async def runPrompt() -> None {
        if onSubmit {
            await invoke_async_callback(onSubmit, draftPrompt);
        }
    }

    return <div className="rounded-[2rem] border border-border bg-panel/90 p-4 shadow-[var(--shadow-glow)] backdrop-blur">
        <div className="flex items-start justify-between gap-3">
            <div>
                <div className="text-xs uppercase tracking-[0.28em] text-accent-2">Always-on-top widget</div>
                <h2 className="mt-2 text-2xl font-semibold text-foreground">RepoGhost</h2>
                <div className="mt-2 text-[11px] uppercase tracking-[0.18em] text-muted">{mode.replace("_", " ")}</div>
                <div className={widget_status_class(loading, error)}>{lastRunLabel}</div>
            </div>
        </div>

        {widget_error_panel(error)}

        <div className="mt-4 grid grid-cols-4 gap-2 text-center text-xs text-muted">
            <div className="rounded-2xl border border-border bg-panel-soft px-3 py-3">
                <div className="text-lg font-semibold text-foreground">{str(len(files))}</div>
                <div>Files</div>
            </div>
            <div className="rounded-2xl border border-border bg-panel-soft px-3 py-3">
                <div className="text-lg font-semibold text-foreground">{str(len(blockers))}</div>
                <div>Blockers</div>
            </div>
            <div className="rounded-2xl border border-border bg-panel-soft px-3 py-3">
                <div className="text-lg font-semibold text-foreground">{str(len(ticketTitles))}</div>
                <div>Tickets</div>
            </div>
            <div className="rounded-2xl border border-border bg-panel-soft px-3 py-3">
                <div className="text-lg font-semibold text-foreground">{str(len(graphNodes))}</div>
                <div>Nodes</div>
            </div>
        </div>

        <div className="mt-4 rounded-[1.5rem] border border-border bg-panel-soft p-4">
            <div className="flex items-center justify-between gap-3">
                <div className="text-xs uppercase tracking-[0.18em] text-muted">Quick chat</div>
                <div className="text-[10px] uppercase tracking-[0.18em] text-muted">{widget_run_label(loading)}</div>
            </div>
            <textarea value={draftPrompt} onChange={lambda e: Any -> None { if onDraft { invoke_callback(onDraft, e.target.value); } }} className="mt-3 min-h-[110px] w-full rounded-2xl border border-border bg-panel px-3 py-3 text-sm text-foreground outline-none transition placeholder:text-muted focus:border-accent" placeholder="Ask RepoGhost what to work on first, what files are involved, or what blockers it sees..." />
            <button onClick={runPrompt} className="mt-3 w-full rounded-2xl bg-accent px-4 py-3 text-sm font-semibold text-background transition hover:brightness-110 disabled:cursor-not-allowed disabled:opacity-60" disabled={loading}>
                {widget_button_label(loading)}
            </button>
        </div>

        <div className="mt-4 rounded-[1.5rem] border border-border bg-panel-soft p-4">
            <div className="text-xs uppercase tracking-[0.18em] text-muted">Next step</div>
            <div className="mt-2 text-sm text-foreground">{nextStep}</div>
        </div>

        <div className="mt-4 space-y-3">
            <div className="rounded-[1.5rem] border border-border bg-panel-soft p-4">
                <div className="text-xs uppercase tracking-[0.18em] text-muted">Relevant files</div>
                <div className="mt-3 space-y-2">{fileCards}</div>
            </div>
            <div className="rounded-[1.5rem] border border-border bg-panel-soft p-4">
                <div className="text-xs uppercase tracking-[0.18em] text-muted">Blockers</div>
                <div className="mt-3 space-y-2">{blockerCards}</div>
            </div>
            <div className="rounded-[1.5rem] border border-border bg-panel-soft p-4">
                <div className="text-xs uppercase tracking-[0.18em] text-muted">Focus paths</div>
                <div className="mt-3 flex flex-wrap gap-2">{focusPills}</div>
            </div>
            <div className="rounded-[1.5rem] border border-border bg-panel-soft p-4">
                <div className="text-xs uppercase tracking-[0.18em] text-muted">Action phases</div>
                <div className="mt-3 space-y-2">{phaseCards}</div>
            </div>
            <div className="rounded-[1.5rem] border border-border bg-panel-soft p-4">
                <div className="text-xs uppercase tracking-[0.18em] text-muted">Handoff</div>
                <div className="mt-3 space-y-2">{handoffCards}</div>
            </div>
        </div>
    </div>;
}
