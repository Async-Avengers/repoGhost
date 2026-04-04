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
        try {
            bundle = await run_workflow(repoPath, meetingText, prompt, mode);
            chatThread = chatThread + [{
                "role": "assistant",
                "content": bundle.action_plan.headline
            }];
        } except Exception as e {
            error = str(e);
        }
        loading = False;
    }

    async can with entry {
        await loadBundle();
    }

    async def submit(nextPrompt: str = "") -> None {
        chosen = nextPrompt or draftPrompt;
        if not chosen {
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
    }

    def setActiveTab(nextTab: str) -> None {
        activeTab = nextTab;
    }

    def applyQuickPrompt(nextMode: str, nextPrompt: str) -> None {
        mode = nextMode;
        draftPrompt = nextPrompt;
    }

    def toggleExpanded() -> None {
        expanded = not expanded;
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
        "submit": submit,
        "setMode": setMode,
        "setRepoPath": setRepoPath,
        "setMeetingText": setMeetingText,
        "setDraftPrompt": setDraftPrompt,
        "setActiveTab": setActiveTab,
        "applyQuickPrompt": applyQuickPrompt,
        "toggleExpanded": toggleExpanded
    };
}
