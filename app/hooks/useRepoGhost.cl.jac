sv import from ..orchestration.workflow { run_workflow }
import from ..lib.ui_state { defaultModes, defaultTabs, quickPrompts }


def:pub useRepoGhost() -> dict {
    has repoPath: str = "c:/workspace/permitted-repo";
    has meetingText: str = "We need to turn meeting context into tickets, blockers, and a handoff. The team wants a visible multi-agent workflow, repo-aware outputs, and a polished demo-ready desktop sidecar.";
    has prompt: str = "Turn this meeting into tickets and show likely files.";
    has draftPrompt: str = prompt;
    has mode: str = "feature_plan";
    has loading: bool = True;
    has error: str = "";
    has bundle: any = None;
    has expanded: bool = True;
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

    async def loadBundle() -> None {
        loading = True;
        error = "";
        lastRunLabel = "Running " + mode + " workflow";
        try {
            nextBundle = await run_workflow(repoPath, meetingText, prompt, mode);
            bundle = nextBundle;
            lastRunLabel = "Completed " + mode + " workflow";
            chatThread = chatThread + [{
                "role": "assistant",
                "content": nextBundle.action_plan.headline
            }];
        } except Exception as e {
            error = str(e);
            lastRunLabel = "Workflow failed";
            chatThread = chatThread + [{
                "role": "assistant",
                "content": "RepoGhost hit an error while processing this run. Review the error banner and try again."
            }];
        }
        loading = False;
    }

    async can with entry {
        await loadBundle();
    }

    async def submit(nextPrompt: str = "") -> None {
        chosen = nextPrompt or draftPrompt;
        if not chosen {
            error = "Add a prompt before running the workflow.";
            return;
        }
        prompt = chosen;
        draftPrompt = chosen;
        chatThread = chatThread + [{"role": "user", "content": chosen}];
        await loadBundle();
    }

    def setMode(nextMode: str) -> None {
        mode = nextMode;
    }

    def setRepoPath(nextPath: str) -> None {
        repoPath = nextPath;
    }

    def setMeetingText(nextText: str) -> None {
        meetingText = nextText;
    }

    def setDraftPrompt(nextPrompt: str) -> None {
        draftPrompt = nextPrompt;
        if error {
            error = "";
        }
    }

    def setActiveTab(nextTab: str) -> None {
        activeTab = nextTab;
    }

    def applyQuickPrompt(nextMode: str, nextPrompt: str) -> None {
        mode = nextMode;
        draftPrompt = nextPrompt;
        error = "";
    }

    def toggleExpanded() -> None {
        expanded = not expanded;
    }

    def dismissError() -> None {
        error = "";
    }

    def graphNodes() -> list {
        if bundle and bundle.context_graph {
            return bundle.context_graph.nodes;
        }
        return [];
    }

    def graphEdges() -> list {
        if bundle and bundle.context_graph {
            return bundle.context_graph.edges;
        }
        return [];
    }

    def graphFocusPaths() -> list[str] {
        if bundle and bundle.context_graph {
            return bundle.context_graph.focus_paths;
        }
        return [];
    }

    def planningResolved() -> list {
        if bundle and bundle.planning {
            return bundle.planning.resolved_mappings;
        }
        return [];
    }

    def planningBlockers() -> list {
        if bundle and bundle.planning {
            return bundle.planning.blocker_insights;
        }
        return [];
    }

    def planningImpacts() -> list {
        if bundle and bundle.planning {
            return bundle.planning.impact_insights;
        }
        return [];
    }

    def planningTestGaps() -> list {
        if bundle and bundle.planning {
            return bundle.planning.test_gap_insights;
        }
        return [];
    }

    def actionPlanPhases() -> list[str] {
        if bundle and bundle.action_plan {
            return bundle.action_plan.phases;
        }
        return [];
    }

    def ticketTitles() -> list[str] {
        titles: list[str] = [];
        if bundle and bundle.tickets {
            for item in bundle.tickets {
                titles.append(item.title);
            }
        }
        return titles;
    }

    def handoffActions() -> list[str] {
        if bundle and bundle.handoff {
            return bundle.handoff.next_actions;
        }
        return [];
    }

    def reviewHotspots() -> list[str] {
        if bundle and bundle.review {
            return bundle.review.risk_hotspots;
        }
        return [];
    }

    def statusTone() -> str {
        if error {
            return "error";
        }
        if loading {
            return "running";
        }
        return "ready";
    }

    return {
        "repoPath": repoPath,
        "meetingText": meetingText,
        "prompt": prompt,
        "draftPrompt": draftPrompt,
        "mode": mode,
        "loading": loading,
        "error": error,
        "bundle": bundle,
        "expanded": expanded,
        "activeTab": activeTab,
        "chatThread": chatThread,
        "lastRunLabel": lastRunLabel,
        "statusTone": statusTone(),
        "modes": defaultModes(),
        "tabs": defaultTabs(),
        "quickPrompts": quickPrompts(),
        "graphNodes": graphNodes(),
        "graphEdges": graphEdges(),
        "graphFocusPaths": graphFocusPaths(),
        "planningResolved": planningResolved(),
        "planningBlockers": planningBlockers(),
        "planningImpacts": planningImpacts(),
        "planningTestGaps": planningTestGaps(),
        "actionPlanPhases": actionPlanPhases(),
        "ticketTitles": ticketTitles(),
        "handoffActions": handoffActions(),
        "reviewHotspots": reviewHotspots(),
        "submit": submit,
        "setMode": setMode,
        "setRepoPath": setRepoPath,
        "setMeetingText": setMeetingText,
        "setDraftPrompt": setDraftPrompt,
        "setActiveTab": setActiveTab,
        "applyQuickPrompt": applyQuickPrompt,
        "toggleExpanded": toggleExpanded,
        "dismissError": dismissError
    };
}
