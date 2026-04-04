def:pub WorkspaceShell(props: dict) -> any {
    bundle = props.bundle;
    tabs = props.tabs or [];
    mode = props.mode or "feature_plan";
    activeTab = props.activeTab or "context";
    chatThread = props.chatThread or [];
    repoPath = props.repoPath or "";
    meetingText = props.meetingText or "";
    draftPrompt = props.draftPrompt or "";
    loading = props.loading or False;
    graphNodes = props.graphNodes or [];
    graphEdges = props.graphEdges or [];
    graphFocusPaths = props.graphFocusPaths or [];
    planningResolved = props.planningResolved or [];
    planningBlockers = props.planningBlockers or [];
    planningImpacts = props.planningImpacts or [];
    planningTestGaps = props.planningTestGaps or [];
    onTab = props.setActiveTab or None;
    onRepo = props.setRepoPath or None;
    onMeeting = props.setMeetingText or None;
    onDraft = props.setDraftPrompt or None;
    onSubmit = props.submit or None;

    trace = (bundle.trace if bundle else []);
    tasks = (bundle.tasks if bundle else []);
    tickets = (bundle.tickets if bundle else []);
    blockers = (bundle.blockers if bundle else []);
    files = (bundle.relevant_files if bundle else []);
    ownership = (bundle.ownership if bundle else []);
    decisions = (bundle.decisions if bundle else []);

    def selectTab(nextTab: str) -> None {
        if onTab {
            onTab(nextTab);
        }
    }

    def updateRepo(e: any) -> None {
        if onRepo {
            onRepo(e.target.value);
        }
    }

    def updateMeeting(e: any) -> None {
        if onMeeting {
            onMeeting(e.target.value);
        }
    }

    def updatePrompt(e: any) -> None {
        if onDraft {
            onDraft(e.target.value);
        }
    }

    async def sendPrompt() -> None {
        if onSubmit {
            await onSubmit(draftPrompt);
        }
    }

    return <div className="grid min-h-[720px] grid-cols-12 gap-4 rounded-[2rem] border border-border bg-panel/90 p-4 shadow-[var(--shadow-glow)] backdrop-blur">
        <aside className="col-span-12 rounded-[1.5rem] border border-border bg-panel-soft p-4 lg:col-span-2">
            <div className="text-xs uppercase tracking-[0.24em] text-muted">Modes</div>
            <div className="mt-3 rounded-2xl border border-accent/30 bg-accent/10 px-3 py-2 text-sm font-medium text-foreground">{mode}</div>
            <div className="mt-6 text-xs uppercase tracking-[0.24em] text-muted">Runs</div>
            <div className="mt-3 space-y-2">
                {[
                    <div key={step.agent} className="rounded-xl border border-border bg-panel px-3 py-2 text-sm text-muted">
                        <div className="font-medium text-foreground">{step.agent}</div>
                        <div className="mt-1 text-xs uppercase tracking-[0.18em]">{step.status}</div>
                    </div>
                    for step in trace
                ]}
            </div>
            <div className="mt-6 text-xs uppercase tracking-[0.24em] text-muted">Graph stats</div>
            <div className="mt-3 grid grid-cols-2 gap-2 text-center text-xs text-muted">
                <div className="rounded-xl border border-border bg-panel px-3 py-3"><div className="text-lg font-semibold text-foreground">{str(len(graphNodes))}</div><div>Nodes</div></div>
                <div className="rounded-xl border border-border bg-panel px-3 py-3"><div className="text-lg font-semibold text-foreground">{str(len(graphEdges))}</div><div>Edges</div></div>
            </div>
            <div className="mt-6 text-xs uppercase tracking-[0.24em] text-muted">Planning stats</div>
            <div className="mt-3 grid grid-cols-2 gap-2 text-center text-xs text-muted">
                <div className="rounded-xl border border-border bg-panel px-3 py-3"><div className="text-lg font-semibold text-foreground">{str(len(planningResolved))}</div><div>Resolved</div></div>
                <div className="rounded-xl border border-border bg-panel px-3 py-3"><div className="text-lg font-semibold text-foreground">{str(len(planningBlockers))}</div><div>Risks</div></div>
            </div>
        </aside>

        <section className="col-span-12 rounded-[1.5rem] border border-border bg-panel-soft p-5 lg:col-span-6">
            <div className="flex items-center justify-between gap-3">
                <div>
                    <div className="text-xs uppercase tracking-[0.24em] text-accent-2">Assistant thread</div>
                    <h3 className="mt-2 text-2xl font-semibold text-foreground">Chat-first engineering workspace</h3>
                </div>
                <div className="rounded-full border border-border px-3 py-1 text-xs text-muted">{("Workflow running" if loading else "Planning context ready")}</div>
            </div>

            <div className="mt-5 grid gap-4 xl:grid-cols-[minmax(0,1fr)_320px]">
                <div className="rounded-[1.5rem] border border-border bg-panel p-4">
                    <div className="space-y-3">
                        {[
                            <div key={str(index)} className={"max-w-[90%] rounded-2xl border px-4 py-3 " + ("ml-auto border-accent/30 bg-accent/10" if item["role"] == "user" else "border-border bg-panel-soft")}>
                                <div className="text-[10px] uppercase tracking-[0.18em] text-muted">{item["role"]}</div>
                                <div className="mt-2 text-sm leading-6 text-foreground">{item["content"]}</div>
                            </div>
                            for (index, item) in enumerate(chatThread)
                        ]}
                    </div>
                    <div className="mt-4 rounded-[1.5rem] border border-border bg-panel-soft p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Compose request</div>
                        <textarea value={draftPrompt} onChange={updatePrompt} className="mt-3 min-h-[120px] w-full rounded-2xl border border-border bg-panel px-3 py-3 text-sm text-foreground outline-none transition placeholder:text-muted focus:border-accent" placeholder="Ask RepoGhost to turn context into tickets, blockers, handoff notes, or review prep..." />
                        <button onClick={sendPrompt} className="mt-3 rounded-2xl bg-accent px-4 py-3 text-sm font-semibold text-background transition hover:brightness-110">Run workflow</button>
                    </div>
                </div>

                <div className="space-y-4">
                    <div className="rounded-[1.5rem] border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Repo input</div>
                        <input value={repoPath} onChange={updateRepo} className="mt-3 w-full rounded-2xl border border-border bg-panel-soft px-3 py-3 text-sm text-foreground outline-none transition focus:border-accent" />
                    </div>
                    <div className="rounded-[1.5rem] border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Meeting input</div>
                        <textarea value={meetingText} onChange={updateMeeting} className="mt-3 min-h-[180px] w-full rounded-2xl border border-border bg-panel-soft px-3 py-3 text-sm text-foreground outline-none transition focus:border-accent" />
                    </div>
                </div>
            </div>

            <div className="mt-4 grid gap-4 xl:grid-cols-[minmax(0,1fr)_320px]">
                <div className="rounded-[1.5rem] border border-border bg-panel p-4">
                    <div className="flex items-center justify-between gap-3">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Agent timeline</div>
                        <div className="text-[10px] uppercase tracking-[0.18em] text-accent-2">Stage 2 merge visible</div>
                    </div>
                    <div className="mt-3 space-y-3">
                        {[
                            <div key={step.agent + step.stage} className="flex items-start gap-3 rounded-2xl border border-border bg-panel-soft px-4 py-3">
                                <div className={"mt-1 h-2.5 w-2.5 rounded-full " + ("bg-success" if step.status == "done" else ("bg-warning" if step.status == "running" else "bg-muted"))} />
                                <div>
                                    <div className="text-sm font-medium text-foreground">{step.agent}</div>
                                    <div className="mt-1 text-xs uppercase tracking-[0.18em] text-muted">{step.stage + " • " + step.status}</div>
                                    <div className="mt-2 text-sm text-muted">{step.detail}</div>
                                </div>
                            </div>
                            for step in trace
                        ]}
                    </div>
                </div>
                <div className="rounded-[1.5rem] border border-border bg-panel p-4">
                    <div className="flex items-center justify-between gap-3">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Graph focus paths</div>
                        <div className="text-[10px] uppercase tracking-[0.18em] text-accent-2">Unified context</div>
                    </div>
                    <div className="mt-3 space-y-2">
                        {[
                            <div key={item} className="rounded-xl border border-border bg-panel-soft px-3 py-2 text-sm text-foreground">{item}</div>
                            for item in graphFocusPaths[0:6]
                        ]}
                    </div>
                </div>
            </div>
        </section>

        <section className="col-span-12 rounded-[1.5rem] border border-border bg-panel-soft p-5 lg:col-span-4">
            <div className="flex flex-wrap gap-2">
                {[
                    <button key={tab["key"]} onClick={lambda : None -> None { selectTab(tab["key"]); }} className={"rounded-full border px-3 py-1 text-xs transition " + ("border-accent bg-accent/15 text-foreground" if tab["key"] == activeTab else "border-border bg-panel text-muted hover:border-border-strong hover:text-foreground")}>
                        {tab["label"]}
                    </button>
                    for tab in tabs
                ]}
            </div>

            <div className="mt-5 space-y-4">
                {activeTab == "context" and (<div className="space-y-4">
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Repo overview</div>
                        <div className="mt-2 text-lg font-semibold text-foreground">{bundle.repo_summary.overview if bundle else "Waiting for workflow bundle."}</div>
                        <div className="mt-4 flex flex-wrap gap-2">{[<div key={item} className="rounded-full border border-border bg-panel-soft px-3 py-1 text-xs text-muted">{item}</div> for item in (bundle.repo_summary.frameworks if bundle else [])]}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Meeting summary</div>
                        <p className="mt-2 text-sm leading-6 text-foreground">{bundle.meeting_summary.summary if bundle else ""}</p>
                        <div className="mt-4 space-y-2">{[
                            <div key={item} className="rounded-xl border border-border bg-panel-soft px-3 py-2 text-sm text-foreground">{item}</div>
                            for item in (bundle.meeting_summary.action_items if bundle else [])
                        ]}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="flex items-center justify-between gap-3">
                            <div className="text-xs uppercase tracking-[0.18em] text-muted">Execution planning context</div>
                            <div className="text-[10px] uppercase tracking-[0.18em] text-accent-2">Stage 2 merged</div>
                        </div>
                        <div className="mt-3 grid gap-3 md:grid-cols-2">
                            <div className="rounded-xl border border-border bg-panel-soft p-3">
                                <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Resolved areas</div>
                                <div className="mt-2 space-y-2">{[<div key={item.title} className="text-sm text-foreground">• {item.title}</div> for item in planningResolved[0:4]]}</div>
                            </div>
                            <div className="rounded-xl border border-border bg-panel-soft p-3">
                                <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Impact hotspots</div>
                                <div className="mt-2 space-y-2">{[<div key={item.title} className="text-sm text-foreground">• {item.title}</div> for item in planningImpacts[0:4]]}</div>
                            </div>
                        </div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="flex items-center justify-between gap-3">
                            <div className="text-xs uppercase tracking-[0.18em] text-muted">Context graph</div>
                            <div className="text-[10px] uppercase tracking-[0.18em] text-accent-2">{str(len(graphNodes))} nodes</div>
                        </div>
                        <div className="mt-3 space-y-2">{[
                            <div key={item.id} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                                <div className="flex items-center justify-between gap-3">
                                    <div className="text-sm font-medium text-foreground">{item.label}</div>
                                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">{item.kind}</div>
                                </div>
                                <div className="mt-1 text-xs text-muted">{item.detail}</div>
                            </div>
                            for item in graphNodes[0:8]
                        ]}</div>
                    </div>
                </div>)}

                {activeTab == "files" and (<div className="rounded-2xl border border-border bg-panel p-4">
                    <div className="text-xs uppercase tracking-[0.18em] text-muted">Relevant files</div>
                    <div className="mt-3 space-y-3">{[
                        <div key={item.path} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                            <div className="flex items-center justify-between gap-3"><div className="text-sm font-medium text-foreground">{item.path}</div><div className="text-[10px] uppercase tracking-[0.18em] text-accent-2">{item.kind}</div></div>
                            <div className="mt-1 text-xs text-muted">{item.rationale}</div>
                            <div className="mt-2 text-[10px] uppercase tracking-[0.18em] text-muted">Score {str(item.score)}</div>
                        </div>
                        for item in files
                    ]}</div>
                </div>)}

                {activeTab == "tasks" and (<div className="rounded-2xl border border-border bg-panel p-4">
                    <div className="text-xs uppercase tracking-[0.18em] text-muted">Tasks</div>
                    <div className="mt-3 space-y-3">{[
                        <div key={task.title} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                            <div className="text-sm font-medium text-foreground">{task.title}</div>
                            <div className="mt-1 text-xs text-muted">{task.summary}</div>
                            <div className="mt-2 text-[10px] uppercase tracking-[0.18em] text-accent-2">{task.phase}</div>
                        </div>
                        for task in tasks
                    ]}</div>
                </div>)}

                {activeTab == "tickets" and (<div className="rounded-2xl border border-border bg-panel p-4">
                    <div className="text-xs uppercase tracking-[0.18em] text-muted">Tickets</div>
                    <div className="mt-3 space-y-3">{[
                        <div key={ticket.title} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                            <div className="flex items-center justify-between gap-3"><div className="text-sm font-medium text-foreground">{ticket.title}</div><div className="rounded-full border border-border px-2 py-0.5 text-[10px] uppercase tracking-[0.18em] text-muted">{ticket.priority}</div></div>
                            <div className="mt-1 text-xs text-muted">{ticket.summary}</div>
                            <div className="mt-3 space-y-1">{[
                                <div key={criterion} className="text-xs text-foreground">• {criterion}</div>
                                for criterion in ticket.acceptance_criteria
                            ]}</div>
                        </div>
                        for ticket in tickets
                    ]}</div>
                </div>)}

                {activeTab == "blockers" and (<div className="space-y-4">
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Blockers</div>
                        <div className="mt-3 space-y-2">{[
                            <div key={item.title} className="rounded-xl border border-danger/30 bg-danger/10 px-3 py-3">
                                <div className="text-sm font-medium text-foreground">{item.title}</div>
                                <div className="mt-1 text-xs text-muted">{item.detail}</div>
                                <div className="mt-2 text-[10px] uppercase tracking-[0.18em] text-danger">{item.severity}</div>
                            </div>
                            for item in blockers
                        ]}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Stage 2 blocker reasoning</div>
                        <div className="mt-3 space-y-2">{[
                            <div key={item.title + item.category} className="rounded-xl border border-warning/30 bg-warning/10 px-3 py-3">
                                <div className="text-sm font-medium text-foreground">{item.title}</div>
                                <div className="mt-1 text-xs text-muted">{item.detail}</div>
                                <div className="mt-2 text-[10px] uppercase tracking-[0.18em] text-warning">{item.severity + " • " + item.category}</div>
                            </div>
                            for item in planningBlockers
                        ]}</div>
                    </div>
                </div>)}

                {activeTab == "handoff" and (<div className="rounded-2xl border border-border bg-panel p-4">
                    <div className="text-xs uppercase tracking-[0.18em] text-muted">Handoff</div>
                    <div className="mt-2 text-sm leading-6 text-foreground">{bundle.handoff.summary if bundle else ""}</div>
                    <div className="mt-4 space-y-2">{[
                        <div key={item} className="rounded-xl border border-border bg-panel-soft px-3 py-2 text-sm text-foreground">{item}</div>
                        for item in (bundle.handoff.next_actions if bundle else [])
                    ]}</div>
                </div>)}

                {activeTab == "standup" and (<div className="rounded-2xl border border-border bg-panel p-4">
                    <div className="text-xs uppercase tracking-[0.18em] text-muted">Standup</div>
                    <div className="mt-3 grid gap-3 md:grid-cols-3">
                        <div className="rounded-xl border border-border bg-panel-soft p-3"><div className="text-[10px] uppercase tracking-[0.18em] text-muted">Done</div><div className="mt-2 space-y-1">{[<div key={item} className="text-sm text-foreground">• {item}</div> for item in (bundle.standup.done if bundle else [])]}</div></div>
                        <div className="rounded-xl border border-border bg-panel-soft p-3"><div className="text-[10px] uppercase tracking-[0.18em] text-muted">Next</div><div className="mt-2 space-y-1">{[<div key={item} className="text-sm text-foreground">• {item}</div> for item in (bundle.standup.next if bundle else [])]}</div></div>
                        <div className="rounded-xl border border-border bg-panel-soft p-3"><div className="text-[10px] uppercase tracking-[0.18em] text-muted">Blockers</div><div className="mt-2 space-y-1">{[<div key={item} className="text-sm text-foreground">• {item}</div> for item in (bundle.standup.blockers if bundle else [])]}</div></div>
                    </div>
                </div>)}

                {activeTab == "review" and (<div className="space-y-4">
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Review scope</div>
                        <div className="mt-2 text-sm leading-6 text-foreground">{bundle.review.summary if bundle else ""}</div>
                        <div className="mt-4 space-y-2">{[
                            <div key={item} className="rounded-xl border border-border bg-panel-soft px-3 py-2 text-sm text-foreground">{item}</div>
                            for item in (bundle.review.checklist if bundle else [])
                        ]}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Dependency impact reasoning</div>
                        <div className="mt-3 space-y-2">{[
                            <div key={item.title + item.category} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                                <div className="text-sm font-medium text-foreground">{item.title}</div>
                                <div className="mt-1 text-xs text-muted">{item.detail}</div>
                                <div className="mt-2 text-[10px] uppercase tracking-[0.18em] text-accent-2">{item.severity}</div>
                            </div>
                            for item in planningImpacts
                        ]}</div>
                    </div>
                </div>)}

                {activeTab == "memory" and (<div className="space-y-4">
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Decisions</div>
                        <div className="mt-3 space-y-2">{[
                            <div key={item.title} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                                <div className="text-sm font-medium text-foreground">{item.title}</div>
                                <div className="mt-1 text-xs text-muted">{item.detail}</div>
                            </div>
                            for item in decisions
                        ]}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Ownership</div>
                        <div className="mt-3 space-y-2">{[
                            <div key={item.area} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                                <div className="text-sm font-medium text-foreground">{item.area}</div>
                                <div className="mt-1 text-xs text-muted">{item.owner + " • " + item.rationale}</div>
                            </div>
                            for item in ownership
                        ]}</div>
                    </div>
                </div>)}

                {activeTab == "trace" and (<div className="space-y-4">
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="text-xs uppercase tracking-[0.18em] text-muted">Trace</div>
                        <div className="mt-3 space-y-3">{[
                            <div key={step.agent + step.stage} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                                <div className="flex items-center justify-between gap-3"><div className="text-sm font-medium text-foreground">{step.agent}</div><div className="text-[10px] uppercase tracking-[0.18em] text-muted">{step.stage}</div></div>
                                <div className="mt-1 text-xs text-muted">{step.detail}</div>
                                <div className="mt-2 text-[10px] uppercase tracking-[0.18em] text-accent-2">{step.status}</div>
                            </div>
                            for step in trace
                        ]}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="flex items-center justify-between gap-3">
                            <div className="text-xs uppercase tracking-[0.18em] text-muted">Test gap reasoning</div>
                            <div className="text-[10px] uppercase tracking-[0.18em] text-accent-2">{str(len(planningTestGaps))} targets</div>
                        </div>
                        <div className="mt-3 space-y-2">{[
                            <div key={item.title + item.category} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                                <div className="text-sm font-medium text-foreground">{item.title}</div>
                                <div className="mt-1 text-xs text-muted">{item.detail}</div>
                                <div className="mt-2 text-[10px] uppercase tracking-[0.18em] text-accent-2">{item.category + " • " + item.severity}</div>
                            </div>
                            for item in planningTestGaps
                        ]}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel p-4">
                        <div className="flex items-center justify-between gap-3">
                            <div className="text-xs uppercase tracking-[0.18em] text-muted">Graph edges</div>
                            <div className="text-[10px] uppercase tracking-[0.18em] text-accent-2">{str(len(graphEdges))} relationships</div>
                        </div>
                        <div className="mt-3 space-y-2">{[
                            <div key={item.source + item.target + item.kind} className="rounded-xl border border-border bg-panel-soft px-3 py-3">
                                <div className="text-sm font-medium text-foreground">{item.kind}</div>
                                <div className="mt-1 text-xs text-muted">{item.source + " → " + item.target}</div>
                                <div className="mt-2 text-xs text-muted">{item.detail}</div>
                            </div>
                            for item in graphEdges[0:10]
                        ]}</div>
                    </div>
                </div>)}
            </div>
        </section>
    </div>;
}
