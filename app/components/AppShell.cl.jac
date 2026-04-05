import from typing { Any }
sv include app.orchestration.workflow;
import from app.components.WidgetShell { WidgetShell }

def mark_used(value: Any) -> None {
    if value {
        return;
    }
}

async def fetchWorkflowBundle(repoPath: str, meetingText: str, prompt: str, mode: str) -> Any {
    return await run_workflow(repoPath, meetingText, prompt, mode);
}

def:pub AppShell() -> JsxElement {
    has repoPath: str = "";
    has meetingText: str = "";
    has prompt: str = "";
    has draftPrompt: str = "";
    has mode: str = "feature_plan";
    has loading: bool = False;
    has error: str = "";
    has bundle: Any = None;
    has activeWidgetTab: str = "context";
    has lastRunLabel: str = "Ready";

    async def loadBundle() -> None {
        loading = True;
        error = "";
        mark_used(error);
        lastRunLabel = "Running " + mode + " workflow";
        assert len(lastRunLabel) >= 0;
        try {
            nextBundle: Any = await fetchWorkflowBundle(repoPath, meetingText, prompt, mode);
            bundle = nextBundle;
            lastRunLabel = "Completed " + mode + " workflow";
            mark_used(lastRunLabel);
        } except ValueError as e {
            error = str(e);
            mark_used(error);
            lastRunLabel = "Workflow failed";
            mark_used(lastRunLabel);
        } except RuntimeError as e {
            error = str(e);
            mark_used(error);
            lastRunLabel = "Workflow failed";
            mark_used(lastRunLabel);
        } except TypeError as e {
            error = str(e);
            mark_used(error);
            lastRunLabel = "Workflow failed";
            mark_used(lastRunLabel);
        } except OSError as e {
            error = str(e);
            mark_used(error);
            lastRunLabel = "Workflow failed";
            mark_used(lastRunLabel);
        }
        loading = False;
    }

    async can with entry {
        if repoPath {
            await loadBundle();
        }
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
        mark_used(prompt);
        draftPrompt = chosen;
        mark_used(draftPrompt);
        await loadBundle();
    }

    def updateRepoPath(nextPath: str) -> None {
        repoPath = nextPath;
        mark_used(repoPath);
    }

    def updateMeetingText(nextText: str) -> None {
        meetingText = nextText;
        mark_used(meetingText);
    }

    def updateDraftPrompt(nextPrompt: str) -> None {
        draftPrompt = nextPrompt;
        mark_used(draftPrompt);
        if error {
            error = "";
            mark_used(error);
        }
    }

    def updateActiveWidgetTab(tab: str) -> None {
        activeWidgetTab = tab;
        mark_used(activeWidgetTab);
    }

    def graph_nodes() -> list[Any] {
        if bundle {
            return bundle.context_graph.nodes;
        }
        return [];
    }

    def graph_focus_paths() -> list[str] {
        if bundle {
            return bundle.context_graph.focus_paths;
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

    def ownership() -> list[Any] {
        if bundle {
            return bundle.ownership;
        }
        return [];
    }

    def standup() -> Any {
        if bundle {
            return bundle.standup;
        }
        return None;
    }

    def decisions() -> list[Any] {
        if bundle {
            return bundle.decisions;
        }
        return [];
    }

    graphNodes: list[Any] = graph_nodes();
    graphFocusPaths: list[str] = graph_focus_paths();
    actionPlanPhases: list[str] = action_plan_phases();
    ticketTitles: list[str] = ticket_titles();
    handoffActions: list[str] = handoff_actions();

    return <div className="flex h-screen items-center justify-center bg-background overflow-hidden">
        <WidgetShell
            bundle={bundle}
            mode={mode}
            draftPrompt={draftPrompt}
            loading={loading}
            error={error}
            lastRunLabel={lastRunLabel}
            activeWidgetTab={activeWidgetTab}
            repoPath={repoPath}
            ownership={ownership()}
            standup={standup()}
            decisions={decisions()}
            graphNodes={graphNodes}
            actionPlanPhases={actionPlanPhases}
            ticketTitles={ticketTitles}
            handoffActions={handoffActions}
            graphFocusPaths={graphFocusPaths}
            setDraftPrompt={updateDraftPrompt}
            setRepoPath={updateRepoPath}
            setActiveWidgetTab={updateActiveWidgetTab}
            submit={submit}
        />
    </div>;
}
