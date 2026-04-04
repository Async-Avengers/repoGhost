import from .core { FileMatch, OwnershipGuess, MeetingSummary, BlockerItem, DecisionItem }
import from .workflow { WorkflowTraceStep, ExecutionPlanningContext }
import from ..graph.builder { ProjectContextGraph }

obj RepoSummary {
    has project_name: str = "RepoGhost";
    has overview: str = "";
    has frameworks: list[str] = [];
    has entry_points: list[str] = [];
    has major_dirs: list[str] = [];
}

obj TaskItem {
    has title: str = "";
    has summary: str = "";
    has phase: str = "";
    has dependencies: list[str] = [];
    has likely_files: list[str] = [];
}

obj ActionPlan {
    has headline: str = "";
    has first_task: str = "";
    has next_task: str = "";
    has phases: list[str] = [];
}

obj GeneratedTicket {
    has title: str = "";
    has summary: str = "";
    has priority: str = "medium";
    has acceptance_criteria: list[str] = [];
    has likely_files: list[str] = [];
    has blockers: list[str] = [];
    has dependencies: list[str] = [];
}

obj HandoffNoteData {
    has summary: str = "";
    has touched_areas: list[str] = [];
    has risks: list[str] = [];
    has next_actions: list[str] = [];
}

obj StandupUpdateData {
    has done: list[str] = [];
    has next: list[str] = [];
    has blockers: list[str] = [];
}

obj ReviewScopeData {
    has summary: str = "";
    has changed_areas: list[str] = [];
    has risk_hotspots: list[str] = [];
    has checklist: list[str] = [];
}

obj WorkflowResultBundle {
    has repo_summary: RepoSummary = RepoSummary();
    has meeting_summary: MeetingSummary = MeetingSummary();
    has relevant_files: list[FileMatch] = [];
    has ownership: list[OwnershipGuess] = [];
    has decisions: list[DecisionItem] = [];
    has blockers: list[BlockerItem] = [];
    has planning: ExecutionPlanningContext = ExecutionPlanningContext();
    has action_plan: ActionPlan = ActionPlan();
    has tasks: list[TaskItem] = [];
    has tickets: list[GeneratedTicket] = [];
    has handoff: HandoffNoteData = HandoffNoteData();
    has standup: StandupUpdateData = StandupUpdateData();
    has review: ReviewScopeData = ReviewScopeData();
    has trace: list[WorkflowTraceStep] = [];
    has context_graph: ProjectContextGraph = ProjectContextGraph();
}
