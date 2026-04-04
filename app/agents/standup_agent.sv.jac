import from app.models.workflow { WorkflowRequest, ExecutionPlanningContext, WorkflowTraceStep }
import from app.models.outputs { StandupUpdateData, TaskItem }


def:pub generate_standup(request: WorkflowRequest, planning: ExecutionPlanningContext, tasks: list[TaskItem], trace: list[WorkflowTraceStep]) -> StandupUpdateData {
    done: list[str] = [
        "Mapped the repo and synced docs into the project context graph across " + str(len(trace)) + " workflow trace steps.",
        "Parsed meeting context and merged Stage 2 reasoning into the planning context.",
        "Prepared Stage 3 output artifacts for execution and communication."
    ];
    next_items: list[str] = [
        "Start with the highest-signal resolved area and confirm scope.",
        "Convert the action plan into tracked implementation work from " + (tasks[0].title if len(tasks) > 0 else "the top task") + ".",
        "Close the top blocker before deeper execution begins."
    ];
    blockers: list[str] = planning.blocker_titles[0:4];
    if request.mode == "standup" {
        next_items[0] = "Share the current execution order and likely files with the team.";
    }
    if len(blockers) == 0 {
        blockers = ["No critical blockers detected; monitor dependency and test-gap risks."];
    }
    return StandupUpdateData(done=done, next=next_items, blockers=blockers);
}
