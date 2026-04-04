import from typing { Any }
sv include app.orchestration.workflow;
import from app.components.WidgetShell { WidgetShell }
import from app.components.WorkspaceShell { WorkspaceShell }

async def fetchWorkflowBundle(repoPath: str, meetingText: str, prompt: str, mode: str) -> Any {
    return await run_workflow(repoPath, meetingText, prompt, mode);
}

def action_plan_text(bundle: Any) -> str {
    if bundle and bundle.action_plan.first_task {
        return bundle.action_plan.first_task;
    }
    return "Waiting for workflow bundle.";
}

def first_list_item(values: list[str], fallback: str) -> str {
    if len(values) > 0 {
        return values[0];
    }
    return fallback;
}

def status_card_class(loading: bool, status_tone: str) -> str {
    if status_tone == "error" {
        return "rounded-2xl border px-4 py-3 border-danger/40 bg-danger/10";
    }
    if loading {
        return "rounded-2xl border px-4 py-3 border-warning/40 bg-warning/10";
    }
    return "rounded-2xl border px-4 py-3 border-success/30 bg-success/10";
}

def workflow_error_panel(error: str) -> JsxElement {
    if error {
        return <div className="mt-4 rounded-2xl border border-danger/40 bg-danger/10 px-4 py-3 text-sm text-foreground">
            <div className="text-[10px] uppercase tracking-[0.18em] text-danger">Workflow error</div>
            <div className="mt-2 leading-6">{error}</div>
        </div>;
    }
    return <div />;
}

def:pub AppShell() -> JsxElement {
    has repoPath: str = "c:/workspace/permitted-repo";
    has meetingText: str = "We need to turn meeting context into tickets, blockers, and a handoff. The team wants a visible multi-agent workflow, repo-aware outputs, and a polished demo-ready desktop sidecar.";
    has prompt: str = "Turn this meeting into tickets and show likely files.";
    has draftPrompt: str = prompt;
    has mode: str = "feature_plan";
    has loading: bool = True;
    has error: str = "";
    has bundle: Any = None;
    has activeTab: str = "context";
    has lastRunLabel: str = "Bootstrapping RepoGhost workspace";
    has chatThread: list[dict[str, str]] = [
        {
            "role": "assistant",
            "content": "RepoGhost is ready. Point me at a permitted repo, paste meeting context, and I will turn it into actionable engineering output."
        },
        {
            "role": "user",
            "content": prompt
        }
    ];

    def appendChatMessage(role: str, content: str) -> None {
        message: dict[str, str] = {
            "role": role,
            "content": content
        };
        messages: list[dict[str, str]] = [];
        for item in chatThread {
            messages.append(item);
        }
        messages.append(message);
        chatThread = messages;
    }

    async def loadBundle() -> None {
        loading = True;
        error = "";
        lastRunLabel = "Running " + mode + " workflow";
        assert len(lastRunLabel) >= 0;
        try {
            nextBundle: Any = await fetchWorkflowBundle(repoPath, meetingText, prompt, mode);
            bundle = nextBundle;
            lastRunLabel = "Completed " + mode + " workflow";
            if nextBundle.action_plan.headline {
                appendChatMessage("assistant", nextBundle.action_plan.headline);
            }
        } except ValueError as e {
            error = str(e);
            lastRunLabel = "Workflow failed";
            if error {
                appendChatMessage("assistant", "RepoGhost hit an error while processing this run. Review the error banner and try again.");
            }
        } except RuntimeError as e {
            error = str(e);
            lastRunLabel = "Workflow failed";
            if error {
                appendChatMessage("assistant", "RepoGhost hit an error while processing this run. Review the error banner and try again.");
            }
        } except TypeError as e {
            error = str(e);
            lastRunLabel = "Workflow failed";
            if error {
                appendChatMessage("assistant", "RepoGhost hit an error while processing this run. Review the error banner and try again.");
            }
        } except OSError as e {
            error = str(e);
            lastRunLabel = "Workflow failed";
            if error {
                appendChatMessage("assistant", "RepoGhost hit an error while processing this run. Review the error banner and try again.");
            }
        }
        loading = False;
    }

    async can with entry {
        await loadBundle();
    }

    async def submit(nextPrompt: str = "") -> None {
        chosen: str = nextPrompt;
        if not chosen {
            chosen = draftPrompt;
        }
        if not chosen {
            error = "Add a prompt before running the workflow.";
            return;
        }
        prompt = chosen;
        draftPrompt = chosen;
        appendChatMessage("user", chosen);
        await loadBundle();
    }

    def updateRepoPath(nextPath: str) -> None {
        repoPath = nextPath;
    }

    def updateMeetingText(nextText: str) -> None {
        meetingText = nextText;
    }

    def updateDraftPrompt(nextPrompt: str) -> None {
        draftPrompt = nextPrompt;
        if error {
            error = "";
        }
    }

    def graph_nodes() -> list[Any] {
        if bundle {
            return bundle.context_graph.nodes;
        }
        return [];
    }

    def graph_edges() -> list[Any] {
        if bundle {
            return bundle.context_graph.edges;
        }
        return [];
    }

    def graph_focus_paths() -> list[str] {
        if bundle {
            return bundle.context_graph.focus_paths;
        }
        return [];
    }

    def planning_resolved() -> list[Any] {
        if bundle {
            return bundle.planning.resolved_mappings;
        }
        return [];
    }

    def planning_blockers() -> list[Any] {
        if bundle {
            return bundle.planning.blocker_insights;
        }
        return [];
    }

    def planning_impacts() -> list[Any] {
        if bundle {
            return bundle.planning.impact_insights;
        }
        return [];
    }

    def planning_test_gaps() -> list[Any] {
        if bundle {
            return bundle.planning.test_gap_insights;
        }
        return [];
    }

    def action_plan_phases() -> list[str] {
        if bundle {
            return bundle.action_plan.phases;
        }
        return [];
    }

    def ticket_titles() -> list[str] {
        titles: list[str] = [];
        if bundle {
            for item in bundle.tickets {
                titles.append(item.title);
            }
        }
        return titles;
    }

    def handoff_actions() -> list[str] {
        if bundle {
            return bundle.handoff.next_actions;
        }
        return [];
    }

    def review_hotspots() -> list[str] {
        if bundle {
            return bundle.review.risk_hotspots;
        }
        return [];
    }

    def status_tone() -> str {
        if error {
            return "error";
        }
        if loading {
            return "running";
        }
        return "ready";
    }

    graphNodes: list[Any] = graph_nodes();
    graphEdges: list[Any] = graph_edges();
    graphFocusPaths: list[str] = graph_focus_paths();
    planningResolved: list[Any] = planning_resolved();
    planningBlockers: list[Any] = planning_blockers();
    planningImpacts: list[Any] = planning_impacts();
    planningTestGaps: list[Any] = planning_test_gaps();
    actionPlanPhases: list[str] = action_plan_phases();
    ticketTitles: list[str] = ticket_titles();
    handoffActions: list[str] = handoff_actions();
    reviewHotspots: list[str] = review_hotspots();
    statusTone: str = status_tone();

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
                        <div className="mt-2 text-sm font-medium text-foreground">{mode}</div>
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
                    <div className="mt-2 text-sm font-medium text-foreground">{action_plan_text(bundle)}</div>
                </div>
                <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Handoff</div>
                    <div className="mt-2 text-sm font-medium text-foreground">{first_list_item(handoffActions, "No handoff actions yet.")}</div>
                </div>
                <div className="rounded-2xl border border-border bg-panel-soft px-4 py-3">
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Review hotspot</div>
                    <div className="mt-2 text-sm font-medium text-foreground">{first_list_item(reviewHotspots, "No review hotspots yet.")}</div>
                </div>
                <div className={status_card_class(loading, statusTone)}>
                    <div className="text-[10px] uppercase tracking-[0.18em] text-muted">Run status</div>
                    <div className="mt-2 text-sm font-medium text-foreground">{lastRunLabel}</div>
                </div>
            </div>
            {workflow_error_panel(error)}
        </header>

        <div className="grid gap-6 xl:grid-cols-[360px_minmax(0,1fr)]">
            <WidgetShell
                bundle={bundle}
                mode={mode}
                draftPrompt={draftPrompt}
                loading={loading}
                error={error}
                lastRunLabel={lastRunLabel}
                graphNodes={graphNodes}
                graphFocusPaths={graphFocusPaths}
                actionPlanPhases={actionPlanPhases}
                ticketTitles={ticketTitles}
                handoffActions={handoffActions}
                setDraftPrompt={updateDraftPrompt}
                submit={submit}
            />
            <WorkspaceShell
                bundle={bundle}
                activeTab={activeTab}
                chatThread={chatThread}
                repoPath={repoPath}
                meetingText={meetingText}
                draftPrompt={draftPrompt}
                loading={loading}
                error={error}
                lastRunLabel={lastRunLabel}
                graphNodes={graphNodes}
                graphEdges={graphEdges}
                graphFocusPaths={graphFocusPaths}
                planningResolved={planningResolved}
                planningBlockers={planningBlockers}
                planningImpacts={planningImpacts}
                planningTestGaps={planningTestGaps}
                reviewHotspots={reviewHotspots}
                setRepoPath={updateRepoPath}
                setMeetingText={updateMeetingText}
                setDraftPrompt={updateDraftPrompt}
                submit={submit}
            />
        </div>
    </div>;
}
