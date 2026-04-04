import from .WidgetShell { WidgetShell }
import from .WorkspaceShell { WorkspaceShell }


def:pub AppShell() -> any {
    state = useRepoGhost();
    bundle = state["bundle"];
    graphNodes = state["graphNodes"];
    graphEdges = state["graphEdges"];
    planningResolved = state["planningResolved"];
    planningBlockers = state["planningBlockers"];
    planningImpacts = state["planningImpacts"];
    planningTestGaps = state["planningTestGaps"];
    actionPlanPhases = state["actionPlanPhases"];
    ticketTitles = state["ticketTitles"];
    handoffActions = state["handoffActions"];
    reviewHotspots = state["reviewHotspots"];
    statusTone = state["statusTone"];
    error = state["error"];
    loading = state["loading"];
    lastRunLabel = state["lastRunLabel"];

    return <div className="mx-auto flex min-h-screen w-full max-w-[1600px] flex-col gap-6 px-4 py-6 lg:px-6">
        <header className="rounded-[2rem] border border-border bg-panel/85 p-5 shadow-[var(--shadow-glow)] backdrop-blur">
            <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
                <div>
                    <div className="text-xs uppercase tracking-[0.28em] text-accent-2">Desktop AI developer sidecar</div>
                    <h1 className="mt-3 text-4xl font-semibold tracking-tight text-foreground">RepoGhost</h1>
                    <p className="mt-3 max-w-3xl text-sm leading-6 text-muted">
                        A graph-native Jac workspace that turns repo context, meeting language, staged reasoning, and Stage 3 output agents into actionable engineering output.
                    </p>
                </div>
                <div className="grid grid-cols-2 gap-3 md:grid-cols-5">
                    <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                        <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Mode</div>
                        <div className="mt-2 text-sm font-medium text-foreground">{state["mode"]}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                        <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Graph</div>
                        <div className="mt-2 text-sm font-medium text-foreground">{str(len(graphNodes)) + " nodes / " + str(len(graphEdges)) + " edges"}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                        <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Planning</div>
                        <div className="mt-2 text-sm font-medium text-foreground">{str(len(planningResolved)) + " resolved / " + str(len(planningImpacts)) + " impacts"}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                        <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Risk</div>
                        <div className="mt-2 text-sm font-medium text-foreground">{str(len(planningBlockers)) + " blockers / " + str(len(planningTestGaps)) + " test gaps"}</div>
                    </div>
                    <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                        <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Outputs</div>
                        <div className="mt-2 text-sm font-medium text-foreground">{str(len(ticketTitles)) + " tickets / " + str(len(actionPlanPhases)) + " phases"}</div>
                    </div>
                </div>
            </div>
            <div className="mt-4 grid gap-3 md:grid-cols-[minmax(0,1fr)_minmax(0,1fr)_minmax(0,1fr)_220px]">
                <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Action plan</div>
                    <div className="mt-2 text-sm font-medium text-foreground">{bundle.action_plan.first_task if bundle else "Waiting for workflow bundle."}</div>
                </div>
                <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Handoff</div>
                    <div className="mt-2 text-sm font-medium text-foreground">{handoffActions[0] if len(handoffActions) > 0 else "No handoff actions yet."}</div>
                </div>
                <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Review hotspot</div>
                    <div className="mt-2 text-sm font-medium text-foreground">{reviewHotspots[0] if len(reviewHotspots) > 0 else "No review hotspots yet."}</div>
                </div>
                <div className={"rounded-2xl border px-4 py-3 " + ("border-danger/40 bg-danger/10" if statusTone == "error" else ("border-warning/40 bg-warning/10" if loading else "border-success/30 bg-success/10"))}>
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Run status</div>
                    <div className="mt-2 text-sm font-medium text-foreground">{lastRunLabel}</div>
                </div>
            </div>
            {error and (<div className="mt-4 rounded-2xl border border-danger/40 bg-danger/10 px-4 py-3 text-sm text-foreground">
                <div className="text-[10px] uppercase tracking-[0.18em] text-danger">Workflow error</div>
                <div className="mt-2 leading-6">{error}</div>
            </div>)}
        </header>

        <div className="grid gap-6 xl:grid-cols-[360px_minmax(0,1fr)]">
            <WidgetShell
                bundle={bundle}
                mode={state["mode"]}
                modes={state["modes"]}
                quickPrompts={state["quickPrompts"]}
                draftPrompt={state["draftPrompt"]}
                loading={loading}
                error={error}
                lastRunLabel={lastRunLabel}
                graphNodes={graphNodes}
                graphEdges={graphEdges}
                graphFocusPaths={state["graphFocusPaths"]}
                actionPlanPhases={actionPlanPhases}
                ticketTitles={ticketTitles}
                handoffActions={handoffActions}
                setMode={state["setMode"]}
                setDraftPrompt={state["setDraftPrompt"]}
                applyQuickPrompt={state["applyQuickPrompt"]}
                submit={state["submit"]}
                toggleExpanded={state["toggleExpanded"]}
            />
            <WorkspaceShell
                bundle={bundle}
                tabs={state["tabs"]}
                mode={state["mode"]}
                activeTab={state["activeTab"]}
                chatThread={state["chatThread"]}
                repoPath={state["repoPath"]}
                meetingText={state["meetingText"]}
                draftPrompt={state["draftPrompt"]}
                loading={loading}
                error={error}
                lastRunLabel={lastRunLabel}
                graphNodes={graphNodes}
                graphEdges={graphEdges}
                graphFocusPaths={state["graphFocusPaths"]}
                planningResolved={planningResolved}
                planningBlockers={planningBlockers}
                planningImpacts={planningImpacts}
                planningTestGaps={planningTestGaps}
                reviewHotspots={reviewHotspots}
                setActiveTab={state["setActiveTab"]}
                setRepoPath={state["setRepoPath"]}
                setMeetingText={state["setMeetingText"]}
                setDraftPrompt={state["setDraftPrompt"]}
                submit={state["submit"]}
            />
        </div>
    </div>;
}
