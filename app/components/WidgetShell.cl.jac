def:pub WidgetShell(props: dict) -> any {
    bundle = props.bundle;
    mode = props.mode or "feature_plan";
    modes = props.modes or [];
    quickPrompts = props.quickPrompts or [];
    draftPrompt = props.draftPrompt or "";
    loading = props.loading or False;
    graphNodes = props.graphNodes or [];
    graphEdges = props.graphEdges or [];
    graphFocusPaths = props.graphFocusPaths or [];
    onMode = props.setMode or None;
    onDraft = props.setDraftPrompt or None;
    onQuick = props.applyQuickPrompt or None;
    onSubmit = props.submit or None;
    onToggle = props.toggleExpanded or None;

    blockers = (bundle.blockers if bundle else []);
    files = (bundle.relevant_files if bundle else []);
    nextStep = (bundle.action_plan.next_task if bundle else "Waiting for workflow context.");
    planning = (bundle.planning if bundle else None);

    def chooseMode(nextMode: str) -> None {
        if onMode {
            onMode(nextMode);
        }
    }

    def updateDraft(e: any) -> None {
        if onDraft {
            onDraft(e.target.value);
        }
    }

    def applyPreset(nextMode: str, nextPrompt: str) -> None {
        if onQuick {
            onQuick(nextMode, nextPrompt);
        }
    }

    async def runPrompt() -> None {
        if onSubmit {
            await onSubmit(draftPrompt);
        }
    }

    def toggleWorkspace() -> None {
        if onToggle {
            onToggle();
        }
    }

    return <div className="rounded-[2rem] border border-border bg-panel/90 p-4 shadow-[var(--shadow-glow)] backdrop-blur">
        <div className="flex items-start justify-between gap-3">
            <div>
                <div className="text-xs uppercase tracking-[0.28em] text-accent-2">Always-on-top widget</div>
                <h2 className="mt-2 text-2xl font-semibold text-foreground">RepoGhost</h2>
                <div className="mt-2 inline-flex rounded-full border border-border bg-panel-soft px-3 py-1 text-xs text-muted">
                    {("Running staged workflow" if loading else "Planning context ready")}
                </div>
            </div>
            <button onClick={toggleWorkspace} className="rounded-full border border-border bg-panel-soft px-3 py-2 text-xs text-muted transition hover:border-border-strong hover:text-foreground">
                Expand
            </button>
        </div>

        <div className="mt-4 grid grid-cols-3 gap-2 text-center text-xs text-muted">
            <div className="rounded-2xl border border-border bg-panel-soft px-3 py-3">
                <div className="text-lg font-semibold text-foreground">{str(len(files))}</div>
                <div>Files</div>
            </div>
            <div className="rounded-2xl border border-border bg-panel-soft px-3 py-3">
                <div className="text-lg font-semibold text-foreground">{str(len(blockers))}</div>
                <div>Blockers</div>
            </div>
            <div className="rounded-2xl border border-border bg-panel-soft px-3 py-3">
                <div className="text-lg font-semibold text-foreground">{str(len(graphNodes))}</div>
                <div>Nodes</div>
            </div>
        </div>

        <div className="mt-4">
            <div className="text-xs uppercase tracking-[0.18em] text-muted">Mode</div>
            <div className="mt-2 flex flex-wrap gap-2">
                {[
                    <button key={item["key"]} onClick={lambda : None -> None { chooseMode(item["key"]); }} className={"rounded-full border px-3 py-1.5 text-xs transition " + ("border-accent bg-accent/15 text-foreground" if item["key"] == mode else "border-border bg-panel-soft text-muted hover:border-border-strong hover:text-foreground")}>
                        {item["label"]}
                    </button>
                    for item in modes
                ]}
            </div>
        </div>

        <div className="mt-4">
            <div className="text-xs uppercase tracking-[0.18em] text-muted">Quick actions</div>
            <div className="mt-2 grid grid-cols-2 gap-2">
                {[
                    <button key={item["label"]} onClick={lambda : None -> None { applyPreset(item["mode"], item["prompt"]); }} className="rounded-2xl border border-border bg-panel-soft px-3 py-3 text-left text-xs text-foreground transition hover:border-accent/40 hover:bg-accent/10">
                        <div className="font-medium">{item["label"]}</div>
                        <div className="mt-1 text-[11px] leading-5 text-muted">{item["prompt"]}</div>
                    </button>
                    for item in quickPrompts[0:6]
                ]}
            </div>
        </div>

        <div className="mt-4 rounded-[1.5rem] border border-border bg-panel-soft p-4">
            <div className="text-xs uppercase tracking-[0.18em] text-muted">Quick chat</div>
            <textarea value={draftPrompt} onChange={updateDraft} className="mt-3 min-h-[110px] w-full rounded-2xl border border-border bg-panel px-3 py-3 text-sm text-foreground outline-none transition placeholder:text-muted focus:border-accent" placeholder="Ask RepoGhost what to work on first, what files are involved, or what blockers it sees..." />
            <button onClick={runPrompt} className="mt-3 w-full rounded-2xl bg-accent px-4 py-3 text-sm font-semibold text-background transition hover:brightness-110">
                Run workflow
            </button>
        </div>

        <div className="mt-4 space-y-3">
            <div className="rounded-[1.5rem] border border-border bg-panel-soft p-4">
                <div className="flex items-center justify-between gap-3">
                    <div className="text-xs uppercase tracking-[0.18em] text-muted">Relevant files</div>
                    <div className="text-[10px] uppercase tracking-[0.18em] text-accent-2">Top matches</div>
                </div>
                <div className="mt-3 space-y-2">
                    {[
                        <div key={item.path} className="rounded-xl border border-border bg-panel px-3 py-2">
                            <div className="text-sm font-medium text-foreground">{item.path}</div>
                            <div className="mt-1 text-xs text-muted">{item.rationale}</div>
                        </div>
                        for item in files[0:3]
                    ]}
                </div>
            </div>

            <div className="rounded-[1.5rem] border border-border bg-panel-soft p-4">
                <div className="flex items-center justify-between gap-3">
                    <div className="text-xs uppercase tracking-[0.18em] text-muted">Blockers</div>
                    <div className="text-[10px] uppercase tracking-[0.18em] text-warning">Stage 2</div>
                </div>
                <div className="mt-3 space-y-2">
                    {[
                        <div key={item.title} className="rounded-xl border border-danger/30 bg-danger/10 px-3 py-2">
                            <div className="text-sm font-medium text-foreground">{item.title}</div>
                            <div className="mt-1 text-xs text-muted">{item.detail}</div>
                        </div>
                        for item in (planning.blocker_insights[0:3] if planning else blockers[0:3])
                    ]}
                </div>
            </div>

            <div className="rounded-[1.5rem] border border-border bg-panel-soft p-4">
                <div className="text-xs uppercase tracking-[0.18em] text-muted">Next step</div>
                <div className="mt-2 text-sm leading-6 text-foreground">{nextStep}</div>
                <div className="mt-3 flex flex-wrap gap-2">
                    {[
                        <div key={item} className="rounded-full border border-border bg-panel px-3 py-1 text-[11px] text-muted">{item}</div>
                        for item in graphFocusPaths[0:3]
                    ]}
                </div>
                <div className="mt-3 text-[11px] text-muted">{str(len(graphEdges)) + " graph relationships are active in the current context."}</div>
            </div>
        </div>
    </div>;
}
