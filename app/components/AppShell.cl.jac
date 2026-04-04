import from ..hooks.useRepoGhost { useRepoGhost }
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

    return <div className="mx-auto flex min-h-screen w-full max-w-[1600px] flex-col gap-6 px-4 py-6 lg:px-6">
        <header className="rounded-[2rem] border border-border bg-panel/85 p-5 shadow-[var(--shadow-glow)] backdrop-blur">
            <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
                <div>
                    <div className="text-xs uppercase tracking-[0.28em] text-accent-2">Desktop AI developer sidecar</div>
                    <h1 className="mt-3 text-4xl font-semibold tracking-tight text-foreground">RepoGhost</h1>
                    <p className="mt-3 max-w-3xl text-sm leading-6 text-muted">
                        A graph-native Jac workspace that turns repo context, meeting language, and staged reasoning into actionable engineering output.
                    </p>
                </div>
                <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
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
                </div>
            </div>
        </header>

        <div className="grid gap-6 xl:grid-cols-[360px_minmax(0,1fr)]">
            <WidgetShell
                bundle={bundle}
                mode={state["mode"]}
                modes={state["modes"]}
                quickPrompts={state["quickPrompts"]}
                draftPrompt={state["draftPrompt"]}
                loading={state["loading"]}
                graphNodes={graphNodes}
                graphEdges={graphEdges}
                graphFocusPaths={state["graphFocusPaths"]}
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
                loading={state["loading"]}
                graphNodes={graphNodes}
                graphEdges={graphEdges}
                graphFocusPaths={state["graphFocusPaths"]}
                planningResolved={planningResolved}
                planningBlockers={planningBlockers}
                planningImpacts={planningImpacts}
                planningTestGaps={planningTestGaps}
                setActiveTab={state["setActiveTab"]}
                setRepoPath={state["setRepoPath"]}
                setMeetingText={state["setMeetingText"]}
                setDraftPrompt={state["setDraftPrompt"]}
                submit={state["submit"]}
            />
        </div>
    </div>;
}
