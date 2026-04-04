import from ..models.workflow { WorkflowRequest, WorkflowTraceStep, ExecutionPlanningContext, PlanningInsight }
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
import from ..graph.builder { build_stage_one_graph }
import from ..agents.context_resolver { resolve_context }
import from ..agents.blocker_detector { detect_blockers }
import from ..agents.dependency_impact { analyze_dependency_impact }
import from ..agents.test_gap { identify_test_gaps }


def build_trace(repo_summary_name: str, meeting_summary_text: str, file_count: int) -> list[WorkflowTraceStep] {
    return [
        WorkflowTraceStep(stage="stage_1", agent="Repo Mapper Agent", status="done", started_at="", finished_at="", detail="Mapped repo structure for " + repo_summary_name + "."),
        WorkflowTraceStep(stage="stage_1", agent="Meeting Interpreter Agent", status="done", started_at="", finished_at="", detail="Parsed meeting context: " + meeting_summary_text),
        WorkflowTraceStep(stage="stage_1", agent="Code Search Agent", status="done", started_at="", finished_at="", detail="Ranked " + str(file_count) + " relevant files."),
        WorkflowTraceStep(stage="stage_1", agent="Docs Sync Agent", status="done", started_at="", finished_at="", detail="Pulled project docs into context."),
        WorkflowTraceStep(stage="stage_1", agent="Decision Memory Agent", status="done", started_at="", finished_at="", detail="Updated session and project memory."),
        WorkflowTraceStep(stage="stage_1_merge", agent="Context Graph Builder", status="done", started_at="", finished_at="", detail="Merged stage 1 outputs into the unified project context graph."),
        WorkflowTraceStep(stage="stage_2", agent="Context Resolver Agent", status="done", started_at="", finished_at="", detail="Resolved vague request language to concrete files and graph focus paths."),
        WorkflowTraceStep(stage="stage_2", agent="Blocker Detector Agent", status="done", started_at="", finished_at="", detail="Surfaced requirement gaps, risky assumptions, and missing contracts."),
        WorkflowTraceStep(stage="stage_2", agent="Dependency Impact Agent", status="done", started_at="", finished_at="", detail="Predicted downstream impact across workflow, graph, and UI surfaces."),
        WorkflowTraceStep(stage="stage_2", agent="Test Gap Agent", status="done", started_at="", finished_at="", detail="Suggested unit, integration, and e2e coverage targets."),
        WorkflowTraceStep(stage="stage_2_merge", agent="Planning Context Merger", status="done", started_at="", finished_at="", detail="Merged Stage 2 reasoning into the execution planning context."),
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

def to_planning_insight(title: str, detail: str, severity: str, category: str) -> PlanningInsight {
    return PlanningInsight(title=title, detail=detail, severity=severity, category=category);
}

def build_planning(request: WorkflowRequest, files: list, blockers: list, graph: any, meeting_summary: any) -> ExecutionPlanningContext {
    resolved_areas: list[str] = [];
    impacts: list[str] = [];
    test_gaps: list[str] = [];
    blocker_titles: list[str] = [];
    resolved_mappings: list[PlanningInsight] = [];
    blocker_insights: list[PlanningInsight] = [];
    impact_insights: list[PlanningInsight] = [];
    test_gap_insights: list[PlanningInsight] = [];

    resolved = resolve_context(request, files, graph);
    blocker_results = detect_blockers(request, meeting_summary, files, graph);
    impact_results = analyze_dependency_impact(request, files, graph);
    gap_results = identify_test_gaps(request, meeting_summary, files);

    for item in resolved {
        resolved_areas.append(item.target);
        resolved_mappings.append(to_planning_insight(item.target, item.rationale, "medium", "resolved"));
    }
    for item in impact_results {
        impacts.append(item.area + " — " + item.detail);
        impact_insights.append(to_planning_insight(item.area, item.detail, item.risk, "impact"));
    }
    for item in gap_results {
        test_gaps.append(item.area + " — " + item.recommendation);
        test_gap_insights.append(to_planning_insight(item.area, item.recommendation, item.risk, item.test_type));
    }
    for blocker in blockers {
        blocker_titles.append(blocker.title);
    }
    for item in blocker_results {
        if item.title not in blocker_titles {
            blocker_titles.append(item.title);
        }
        blocker_insights.append(to_planning_insight(item.title, item.detail, item.severity, item.impacted_area));
    }

    return ExecutionPlanningContext(
        resolved_areas=resolved_areas,
        impacts=impacts,
        test_gaps=test_gaps,
        blocker_titles=blocker_titles,
        resolved_mappings=resolved_mappings,
        blocker_insights=blocker_insights,
        impact_insights=impact_insights,
        test_gap_insights=test_gap_insights
    );
}

def build_tasks(files: list, planning: ExecutionPlanningContext) -> list[TaskItem] {
    likely_files: list[str] = [];
    for item in files[:4] {
        likely_files.append(item.path);
    }
    return [
        TaskItem(title="Ingest repo structure", summary="Scan the permitted repo and extract high-signal files.", phase="Stage 1", dependencies=["repo path"], likely_files=likely_files),
        TaskItem(title="Interpret meeting context", summary="Extract actions, blockers, decisions, and systems from meeting text.", phase="Stage 1", dependencies=["meeting text"], likely_files=["app/services/meeting_parse.sv.jac"]),
        TaskItem(title="Resolve execution context", summary="Map vague request language to concrete files, modules, and graph focus paths.", phase="Stage 2", dependencies=["stage 1 graph"], likely_files=planning.resolved_areas[0:4]),
        TaskItem(title="Merge unified project context graph", summary="Attach repo, meeting, docs, search, and memory outputs into one graph-backed context.", phase="Stage 1 Merge", dependencies=["stage 1 outputs"], likely_files=["app/graph/builder.jac", "app/orchestration/workflow.sv.jac"]),
        TaskItem(title="Prepare execution outputs", summary="Turn merged context into tickets, handoff, and standup artifacts.", phase="Stage 3", dependencies=["planning context"], likely_files=["app/orchestration/workflow.sv.jac"])
    ];
}

def build_tickets(files: list, blockers: list, mode: str, planning: ExecutionPlanningContext) -> list[GeneratedTicket] {
    likely_files: list[str] = [];
    blocker_titles: list[str] = [];
    for item in files[:5] {
        likely_files.append(item.path);
    }
    for blocker in blockers {
        blocker_titles.append(blocker.title);
    }
    for item in planning.blocker_titles {
        if item not in blocker_titles {
            blocker_titles.append(item);
        }
    }
    title = "Implement RepoGhost stage 2 reasoning pipeline";
    summary = "Wire context resolution, blocker detection, dependency impact, and test-gap reasoning into the execution planning context.";
    if mode == "bug_fix" {
        title = "Investigate likely regression path from meeting context";
        summary = "Use repo search, graph-backed context, and Stage 2 reasoning to isolate impacted files, blockers, and missing tests.";
    }
    return [GeneratedTicket(title=title, summary=summary, priority="high", acceptance_criteria=["Context resolver maps request language to concrete files", "Blocker detector surfaces requirement and dependency gaps", "Dependency impact reasoning identifies downstream modules", "Test gap reasoning suggests coverage targets", "Execution planning context merges all Stage 2 outputs"], likely_files=likely_files + planning.resolved_areas[0:3], blockers=blocker_titles, dependencies=["repo access", "meeting context", "stage 1 graph"] )];
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
    bundle.context_graph = build_stage_one_graph(
        request,
        repo_summary,
        meeting_summary,
        merged_files,
        merged_decisions,
        merged_blockers,
        bundle.ownership,
        bundle.planning,
        bundle.tasks,
        bundle.tickets,
        bundle.handoff,
        bundle.standup,
        bundle.review,
        bundle.trace
    );
    bundle.planning = build_planning(request, merged_files, merged_blockers, bundle.context_graph, meeting_summary);
    bundle.tasks = build_tasks(merged_files, bundle.planning);
    bundle.tickets = build_tickets(merged_files, merged_blockers, request.mode, bundle.planning);
    bundle.action_plan = ActionPlan(
        headline="RepoGhost is grounding the request in live repo, meeting, and planning context.",
        first_task="Review the resolved files and Stage 2 blocker insights.",
        next_task="Inspect dependency impact and test-gap recommendations before execution.",
        phases=["Stage 1 ingest", "Stage 1 merge", "Stage 2 reasoning", "Stage 2 merge", "Stage 3 outputs"]
    );
    bundle.handoff = HandoffNoteData(
        summary="Stage 2 reasoning now enriches the graph-backed workflow with resolved context, blockers, impact, and test gaps.",
        touched_areas=["context resolution", "blocker detection", "dependency impact", "test gap reasoning", "execution planning context"],
        risks=["Reasoning is currently heuristic-first", "Persistent memory is currently local in-process state"],
        next_actions=["Use planning insights to drive Stage 3 output agents", "Persist memory to disk", "Add byLLM-backed structured reasoning upgrades"]
    );
    bundle.standup = StandupUpdateData(
        done=["Scanned repo structure", "Parsed meeting context", "Ranked relevant files", "Merged stage 1 outputs into the context graph", "Merged Stage 2 reasoning into execution planning"],
        next=["Generate tickets and handoff artifacts from planning insights", "Refine UI panels for impact and test gaps"],
        blockers=bundle.planning.blocker_titles
    );
    bundle.review = ReviewScopeData(
        summary="Review the Stage 2 reasoning agents, planning merge, and UI surfaces for blockers, impact, and test gaps.",
        changed_areas=["app/agents/context_resolver.sv.jac", "app/agents/blocker_detector.sv.jac", "app/agents/dependency_impact.sv.jac", "app/agents/test_gap.sv.jac", "app/orchestration/workflow.sv.jac"],
        risk_hotspots=["heuristic context resolution", "blocker duplication", "impact over-reporting", "test-gap prioritization"],
        checklist=["Stage 2 agents run after Stage 1 merge", "Execution planning context contains merged insights", "UI renders blocker, impact, and test-gap reasoning", "Workflow trace shows Stage 2 merge"]
    );
    bundle.trace = build_trace(repo_summary.project_name, meeting_summary.summary, len(merged_files));
    bundle.context_graph = build_stage_one_graph(
        request,
        repo_summary,
        meeting_summary,
        merged_files,
        merged_decisions,
        merged_blockers,
        bundle.ownership,
        bundle.planning,
        bundle.tasks,
        bundle.tickets,
        bundle.handoff,
        bundle.standup,
        bundle.review,
        bundle.trace
    );

    if request.prompt {
        bundle.action_plan.headline = "Current request: " + request.prompt;
    }
    if request.mode == "standup" {
        bundle.action_plan.headline = "Current request: generate a standup update grounded in repo, meeting, graph, and planning context.";
    } elif request.mode == "handoff" {
        bundle.action_plan.headline = "Current request: prepare a handoff grounded in repo, meeting, graph, and planning context.";
    } elif request.mode == "review_prep" {
        bundle.action_plan.headline = "Current request: prepare review scope from live stage 1 outputs and Stage 2 reasoning.";
    }

    remember_session(request, bundle);
    memory_snapshot = update_project_memory(request.repo_path, bundle);
    bundle.review.checklist = bundle.review.checklist + ["Memory updated at " + memory_snapshot["updated_at"]];
    return bundle;
}

def:pub get_memory_snapshot(repo_path: str) -> dict {
    return get_project_memory(repo_path);
}
