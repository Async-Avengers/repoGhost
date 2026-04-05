import from app.models.core { FileMatch, MeetingSummary }
import from app.models.workflow { WorkflowRequest, ExecutionPlanningContext }
import from app.models.outputs { ActionPlan, TaskItem }


def collect_dependencies(planning: ExecutionPlanningContext) -> list[str] {
    deps: list[str] = [];
    for item in planning.blocker_titles[0:4] {
        deps.append(item);
    }
    if len(deps) == 0 {
        deps = ["repo access", "meeting context", "planning context"];
    }
    return deps;
}

def plan_headline(request: WorkflowRequest, files: list[FileMatch]) -> str {
    if request.mode == "review_prep" {
        return "RepoGhost prepared a reviewer-focused execution plan from repo, meeting, graph, and planning context.";
    }
    return "RepoGhost generated a staged execution plan from " + str(len(files)) + " repo-grounded files and the merged planning context.";
}

def plan_first_task(request: WorkflowRequest, planning: ExecutionPlanningContext, files: list[FileMatch]) -> str {
    if request.mode == "standup" {
        return "Summarize completed context-building and reasoning work for the team update.";
    }
    if request.mode == "handoff" {
        return "Capture the current state of the repo, planning context, and open risks.";
    }
    if request.mode == "review_prep" {
        return "Group changed areas and risk hotspots into a reviewer-friendly scope.";
    }
    if len(planning.resolved_areas) > 0 {
        return "Inspect " + planning.resolved_areas[0] + " and confirm the implementation boundary.";
    }
    if len(files) > 0 {
        return "Inspect " + files[0].path + " and confirm the implementation boundary.";
    }
    return "Validate the top resolved files against the current request.";
}

def plan_next_task(request: WorkflowRequest) -> str {
    if request.mode == "standup" {
        return "Highlight the next execution slice and any blockers that need owner follow-up.";
    }
    if request.mode == "handoff" {
        return "Package next actions for the incoming developer with likely files and dependencies.";
    }
    if request.mode == "review_prep" {
        return "Generate a checklist grounded in blockers, impacts, and test gaps.";
    }
    return "Turn the planning context into execution-ready tickets and handoff artifacts.";
}


def:pub build_action_plan(request: WorkflowRequest, planning: ExecutionPlanningContext, files: list[FileMatch]) -> ActionPlan {
    return ActionPlan(
        headline=plan_headline(request, files),
        first_task=plan_first_task(request, planning, files),
        next_task=plan_next_task(request),
        phases=["Stage 1 ingest", "Stage 1 merge", "Stage 2 reasoning", "Stage 2 merge", "Stage 3 output generation", "Execution handoff"]
    );
}


def:pub build_action_tasks(request: WorkflowRequest, planning: ExecutionPlanningContext, files: list[FileMatch], meeting: MeetingSummary) -> list[TaskItem] {
    likely_files: list[str] = [];
    for item in files {
        if len(likely_files) >= 5 {
            break;
        }
        likely_files.append(item.path);
    }

    if meeting and len(meeting.action_items) > 0 {
        tasks: list[TaskItem] = [];
        for action in meeting.action_items {
            if len(tasks) >= 6 {
                break;
            }
            tasks.append(TaskItem(
                title=action,
                summary="Action item extracted from meeting context.",
                phase="Execution",
                dependencies=[],
                likely_files=likely_files
            ));
        }
        return tasks;
    }

    deps = collect_dependencies(planning);
    tasks: list[TaskItem] = [
        TaskItem(
            title="Confirm execution boundary",
            summary="Use resolved areas and graph focus paths to lock the scope before implementation starts.",
            phase="Phase A",
            dependencies=deps,
            likely_files=planning.resolved_areas[0:4]
        ),
        TaskItem(
            title="Address blocker and dependency risks",
            summary="Resolve missing requirements, contracts, and downstream dependencies surfaced by Stage 2.",
            phase="Phase B",
            dependencies=planning.blocker_titles[0:4],
            likely_files=likely_files
        ),
        TaskItem(
            title="Implement and validate changes",
            summary="Execute the work in the highest-signal files and cover the riskiest paths with tests.",
            phase="Phase C",
            dependencies=["confirmed scope", "risk review"],
            likely_files=likely_files
        )
    ];
    if request.mode == "meeting_to_tickets" {
        tasks[0].title = "Convert meeting language into execution slices";
        tasks[0].summary = "Turn action items, decisions, and blockers into a prioritized engineering sequence.";
    }
    return tasks;
}
