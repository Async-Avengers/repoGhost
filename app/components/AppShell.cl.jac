import from ..hooks.useRepoGhost { useRepoGhost }
import from .WidgetShell { WidgetShell }
import from .WorkspaceShell { WorkspaceShell }
import from .ErrorBanner { ErrorBanner }

def:pub AppShell() -> JsxElement {
    state = useRepoGhost();

    return <div className="mx-auto flex min-h-screen w-full max-w-[1600px] flex-col gap-6 px-4 py-6 lg:px-6">
        <div className="flex flex-col gap-4 rounded-[2rem] border border-border bg-panel/80 p-6 shadow-[var(--shadow-glow)] backdrop-blur xl:flex-row xl:items-end xl:justify-between">
            <div>
                <div className="text-xs uppercase tracking-[0.32em] text-accent-2">Repo-aware developer sidecar</div>
                <h1 className="mt-3 text-4xl font-bold tracking-tight text-foreground">RepoGhost</h1>
                <p className="mt-3 max-w-3xl text-sm leading-7 text-muted">
                    A graph-native Jac workspace that ingests repo structure and meeting context, merges Stage 1 outputs into a unified project context graph, and turns developer conversation into actionable engineering output.
                </p>
            </div>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
                <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3 text-center">
                    <div className="text-lg font-semibold text-foreground">{str(len(state["graphNodes"]))}</div>
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Graph nodes</div>
                </div>
                <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3 text-center">
                    <div className="text-lg font-semibold text-foreground">{str(len(state["graphEdges"]))}</div>
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Graph edges</div>
                </div>
                <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3 text-center">
                    <div className="text-lg font-semibold text-foreground">{str(len(state["bundle"].trace if state["bundle"] else []))}</div>
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Trace steps</div>
                </div>
                <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3 text-center">
                    <div className="text-lg font-semibold text-foreground">{state["mode"]}</div>
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Current mode</div>
                </div>
            </div>
        </div>

        {state["error"] and <ErrorBanner message={state["error"]} />}

        <div className="grid gap-6 xl:grid-cols-[380px_minmax(0,1fr)]">
            <div className="xl:sticky xl:top-6 xl:self-start">
                <WidgetShell
                    bundle={state["bundle"]}
                    mode={state["mode"]}
                    modes={state["modes"]}
                    quickPrompts={state["quickPrompts"]}
                    draftPrompt={state["draftPrompt"]}
                    loading={state["loading"]}
                    expanded={state["expanded"]}
                    graphNodes={state["graphNodes"]}
                    graphEdges={state["graphEdges"]}
                    graphFocusPaths={state["graphFocusPaths"]}
                    setMode={state["setMode"]}
                    toggleExpanded={state["toggleExpanded"]}
                    setDraftPrompt={state["setDraftPrompt"]}
                    submit={state["submit"]}
                    applyQuickPrompt={state["applyQuickPrompt"]}
                />
            </div>

            {state["expanded"] and <WorkspaceShell
                bundle={state["bundle"]}
                tabs={state["tabs"]}
                mode={state["mode"]}
                activeTab={state["activeTab"]}
                chatThread={state["chatThread"]}
                repoPath={state["repoPath"]}
                meetingText={state["meetingText"]}
                draftPrompt={state["draftPrompt"]}
                loading={state["loading"]}
                graphNodes={state["graphNodes"]}
                graphEdges={state["graphEdges"]}
                graphFocusPaths={state["graphFocusPaths"]}
                setActiveTab={state["setActiveTab"]}
                setRepoPath={state["setRepoPath"]}
                setMeetingText={state["setMeetingText"]}
                setDraftPrompt={state["setDraftPrompt"]}
                submit={state["submit"]}
            />}
        </div>
    </div>;
}
