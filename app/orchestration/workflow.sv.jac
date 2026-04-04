import from ..models.workflow { WorkflowRequest, WorkflowTraceStep, ExecutionPlanningContext }
import from ..models.core { DecisionItem, BlockerItem, OwnershipGuess }
import from ..models.outputs {
    ActionPlan, GeneratedTicket, HandoffNoteData, ReviewScopeData,
    StandupUpdateData, TaskItem, WorkflowResultBundle
}
import from ..services.demo_data { get_demo_bundle }
import from ..services.repo_ingest { summarize_repo }
import from ..services.search_index { search_repo }
import from ..services.meeting_parse { parse_meeting }
import from ..services.docs_sync { sync_docs }
import from ..services.memory_store { remember_session, update_project_memory, get_project_memory }

def build_trace(repo_summary_name: str, meeting_summary_text: str, file_count: int) -> list[WorkflowTraceStep] {
    return [
        WorkflowTraceStep(stage="stage_1", agent="Repo Mapper Agent", status="done", started_at="", finished_at="", detail="Mapped repo structure for " + repo_summary_name + "."),
        WorkflowTraceStep(stage="stage_1", agent="Meeting Interpreter Agent", status="done", started_at="", finished_at="", detail="Parsed meeting context: " + meeting_summary_text),
        WorkflowTraceStep(stage="stage_1", agent="Code Search Agent", status="done", started_at="", finished_at="", detail="Ranked " + str(file_count) + " relevant files."),
        WorkflowTraceStep(stage="stage_1", agent="Docs Sync Agent", status="done", started_at="", finished_at="", detail="Pulled project docs into context."),
        WorkflowTraceStep(stage="stage_1", agent="Decision Memory Agent", status="done", started_at="", finished_at="", detail="Updated session and project memory."),
        WorkflowTraceStep(stage="stage_2", agent="Context Resolver Agent", status="queued", started_at="", finished_at="", detail="Stage 2 reasoning will resolve vague requests to concrete modules."),
        WorkflowTraceStep(stage="stage_3", agent="Ticket Writer Agent", status="queued", started_at="", finished_at="", detail="Stage 3 output agents will generate tickets and handoff artifacts.")
    ];
}

def build_ownership(repo_summary_name: str, files: list) -> list[OwnershipGuess] {
    ownership: list[OwnershipGuess] = [];
    if len(files) > 0 {
        ownership.append(OwnershipGuess(area="repo", owner="Core Maintainers", confidence=0.58, rationale="Ownership inferred from top-level structure in " + repo_summary_name + "."));
    }
    for item in files {
        if item.path.startswith("app/components") {
            ownership.append(OwnershipGuess(area="ui", owner="Frontend Team", confidence=0.71, rationale="UI modules cluster under app/components."));
            break;
        }
    }
    return ownership;
}

def build_planning(files: list, blockers: list) -> ExecutionPlanningContext {
    resolved_areas: list[str] = [];
    impacts: list[str] = [];
    test_gaps: list[str] = [];
    blocker_titles: list[str] = [];
    for item in files[:6] {
        resolved_areas.append(item.path);
    }
    impacts = ["repo ingestion", "search ranking", "docs sync", "session memory"];
    test_gaps = ["ignore rules", "meeting parsing edge cases", "workflow endpoint error handling"];
    for blocker in blockers {
        blocker_titles.append(blocker.title);
    }
    return ExecutionPlanningContext(resolved_areas=resolved_areas, impacts=impacts, test_gaps=test_gaps, blocker_titles=blocker_titles);
}

def build_tasks(files: list) -> list[TaskItem] {
    likely_files: list[str] = [];
    for item in files[:4] {
        likely_files.append(item.path);
    }
    return [
        TaskItem(title="Ingest repo structure", summary="Scan the permitted repo and extract high-signal files.", phase="Stage 1", dependencies=["repo path"], likely_files=likely_files),
        TaskItem(title="Interpret meeting context", summary="Extract actions, blockers, decisions, and systems from meeting text.", phase="Stage 1", dependencies=["meeting text"], likely_files=["app/services/meeting_parse.sv.jac"]),
        TaskItem(title="Prepare execution outputs", summary="Turn merged context into tickets, handoff, and standup artifacts.", phase="Stage 3", dependencies=["planning context"], likely_files=["app/orchestration/workflow.sv.jac"])
    ];
}

def build_tickets(files: list, blockers: list, mode: str) -> list[GeneratedTicket] {
    likely_files: list[str] = [];
    blocker_titles: list[str] = [];
    for item in files[:5] {
        likely_files.append(item.path);
    }
    for blocker in blockers {
        blocker_titles.append(blocker.title);
    }
    title = "Implement RepoGhost stage 1 ingestion pipeline";
    summary = "Wire repo ingestion, meeting parsing, docs sync, and search into the workflow orchestrator.";
    if mode == "bug_fix" {
        title = "Investigate likely regression path from meeting context";
        summary = "Use repo search and meeting parsing to isolate the most likely impacted files and blockers.";
    }
    return [GeneratedTicket(title=title, summary=summary, priority="high", acceptance_criteria=["Repo scan returns relevant files", "Meeting parse extracts blockers and decisions", "Workflow bundle reflects real stage 1 outputs"], likely_files=likely_files, blockers=blocker_titles, dependencies=["repo access", "meeting context"] )];
}

def:pub run_workflow(repo_path: str, meeting_text: str, prompt: str, mode: str = "feature_plan") -> WorkflowResultBundle {
    request = WorkflowRequest(repo_path=repo_path, meeting_text=meeting_text, prompt=prompt, mode=mode);
    bundle = get_demo_bundle();

    repo_summary = summarize_repo(request.repo_path);
    meeting_summary = parse_meeting(request.meeting_text);
    relevant_files = search_repo(request.repo_path, request.prompt, request.meeting_text);
    doc_result = sync_docs(request.repo_path);
    doc_files = doc_result[0];
    doc_decisions = doc_result[1];

    merged_files = relevant_files + doc_files;
    merged_decisions = meeting_summary.decisions + doc_decisions;
    merged_blockers = meeting_summary.blockers;
    if len(merged_blockers) == 0 {
        merged_blockers = bundle.blockers;
    }

    bundle.repo_summary = repo_summary;
    bundle.meeting_summary = meeting_summary;
    bundle.relevant_files = merged_files;
    bundle.decisions = merged_decisions;
    bundle.blockers = merged_blockers;
    bundle.ownership = build_ownership(repo_summary.project_name, merged_files);
    bundle.planning = build_planning(merged_files, merged_blockers);
    bundle.tasks = build_tasks(merged_files);
    bundle.tickets = build_tickets(merged_files, merged_blockers, request.mode);
    bundle.action_plan = ActionPlan(
        headline="RepoGhost is grounding the request in live repo and meeting context.",
        first_task="Review the top-ranked files and extracted meeting actions.",
        next_task="Promote stage 1 outputs into the unified project context graph.",
        phases=["Stage 1 ingest", "Stage 2 reasoning", "Stage 3 outputs"]
    );
    bundle.handoff = HandoffNoteData(
        summary="Stage 1 services are now producing real repo-aware context for the current request.",
        touched_areas=["repo ingestion", "search", "meeting parsing", "docs sync", "memory"],
        risks=["Hybrid ranking is heuristic-first", "Persistent memory is currently local in-process state"],
        next_actions=["Merge stage 1 outputs into graph nodes", "Add stage 2 reasoning agents", "Persist memory to disk"]
    );
    bundle.standup = StandupUpdateData(
        done=["Scanned repo structure", "Parsed meeting context", "Ranked relevant files"],
        next=["Merge stage 1 outputs into graph", "Add blocker and impact reasoning"],
        blockers=[item.title for item in merged_blockers]
    );
    bundle.review = ReviewScopeData(
        summary="Review the new stage 1 service layer and workflow wiring.",
        changed_areas=["app/services", "app/agents", "app/orchestration/workflow.sv.jac", "main.jac"],
        risk_hotspots=["repo path handling", "search ranking heuristics", "memory persistence strategy"],
        checklist=["Endpoints imported in main.jac", "Workflow returns typed bundle", "UI renders live stage 1 outputs"]
    );
    bundle.trace = build_trace(repo_summary.project_name, meeting_summary.summary, len(merged_files));

    if request.prompt {
        bundle.action_plan.headline = "Current request: " + request.prompt;
    }
    if request.mode == "standup" {
        bundle.action_plan.headline = "Current request: generate a standup update grounded in repo and meeting context.";
    } elif request.mode == "handoff" {
        bundle.action_plan.headline = "Current request: prepare a handoff grounded in repo and meeting context.";
    } elif request.mode == "review_prep" {
        bundle.action_plan.headline = "Current request: prepare review scope from live stage 1 outputs.";
    }

    remember_session(request, bundle);
    memory_snapshot = update_project_memory(request.repo_path, bundle);
    bundle.review.checklist = bundle.review.checklist + ["Memory updated at " + memory_snapshot["updated_at"]];
    return bundle;
}

def:pub get_memory_snapshot(repo_path: str) -> dict {
    return get_project_memory(repo_path);
}
