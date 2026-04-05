import from os { path }
import from traceback { print_exc }
import from app.models.workflow { WorkflowRequest, WorkflowTraceStep, ExecutionPlanningContext, PlanningInsight }
import from app.models.core { DecisionItem, BlockerItem, FileMatch, MeetingSummary, OwnershipGuess }
import from app.models.outputs {
    ActionPlan, GeneratedTicket, HandoffNoteData, RepoSummary, ReviewScopeData,
    ProjectContextGraph, StandupUpdateData, TaskItem, WorkflowResultBundle
}
include app.services.demo_data;
import from app.services.memory_store { remember_session, update_project_memory, get_project_memory }
import from app.graph.builder { build_stage_one_graph }
include app.agents.repo_mapper;
include app.agents.meeting_interpreter;
include app.agents.code_search;
import from app.agents.context_resolver { resolve_context }
import from app.agents.blocker_detector { detect_blockers }
import from app.agents.dependency_impact { analyze_dependency_impact }
import from app.agents.test_gap { identify_test_gaps }
include app.agents.action_planner;
include app.agents.ticket_writer;
include app.agents.standup_agent;
include app.agents.handoff_agent;
include app.agents.review_prep;

obj WorkflowDocsContext {
    has files: list[FileMatch] = [];
    has decisions: list[DecisionItem] = [];
}

def read_workflow_doc_text(file_path: str) -> str {
    try {
        with open(file_path, "r", encoding="utf-8") as handle {
            return handle.read();
        }
    } except OSError {
        return "";
    } except UnicodeError {
        return "";
    }
}

def workflow_doc_lines(text: str) -> list[str] {
    return text.split("\n");
}

def workflow_trim_text(text: str) -> str {
    return text.strip();
}

def collect_workflow_docs(repo_path: str) -> WorkflowDocsContext {
    docs: list[FileMatch] = [];
    decisions: list[DecisionItem] = [];
    if not repo_path {
        return WorkflowDocsContext(files=docs, decisions=decisions);
    }
    candidates: list[str] = ["README.md", "readme.md", "docs/README.md", "SPEC.md", "docs/spec.md"];
    for rel_path in candidates {
        full_path = path.join(repo_path, rel_path.replace("/", path.sep));
        if not path.exists(full_path) {
            continue;
        }
        docs.append(
            FileMatch(
                path=rel_path,
                score=0.76,
                rationale="Documentation file pulled into project context.",
                kind="doc"
            )
        );
        content: str = read_workflow_doc_text(full_path);
        if not content {
            continue;
        }
        content_lines: list[str] = workflow_doc_lines(content);
        for line in content_lines {
            stripped: str = workflow_trim_text(line);
            if stripped {
                decisions.append(
                    DecisionItem(
                        title="Doc summary",
                        detail=stripped,
                        confidence=0.61,
                        source=rel_path
                    )
                );
                break;
            }
        }
    }
    return WorkflowDocsContext(files=docs, decisions=decisions);
}


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
        WorkflowTraceStep(stage="stage_3", agent="Action Planner Agent", status="done", started_at="", finished_at="", detail="Generated a staged execution order and next-step plan."),
        WorkflowTraceStep(stage="stage_3", agent="Ticket Writer Agent", status="done", started_at="", finished_at="", detail="Created ticket-ready tasks with acceptance criteria and likely files."),
        WorkflowTraceStep(stage="stage_3", agent="Standup Agent", status="done", started_at="", finished_at="", detail="Prepared a concise done, next, blockers update."),
        WorkflowTraceStep(stage="stage_3", agent="Handoff Agent", status="done", started_at="", finished_at="", detail="Prepared next-developer handoff notes with risks and next actions."),
        WorkflowTraceStep(stage="stage_3", agent="PR Review Prep Agent", status="done", started_at="", finished_at="", detail="Prepared review scope, hotspots, and reviewer checklist."),
        WorkflowTraceStep(stage="stage_3_merge", agent="Output Bundle Merger", status="done", started_at="", finished_at="", detail="Merged Stage 3 artifacts into the final structured workflow bundle.")
    ];
}


def dir_area_label(segment: str) -> str {
    if segment in ["components", "component"] { return "UI Components"; }
    if segment in ["pages", "page", "views", "view", "screens"] { return "Pages / Views"; }
    if segment in ["api", "routes", "route", "endpoints"] { return "API Routes"; }
    if segment in ["controllers", "controller", "handlers"] { return "Controllers"; }
    if segment in ["services", "service"] { return "Services"; }
    if segment in ["agents", "agent"] { return "Agents"; }
    if segment in ["models", "model", "schema", "schemas", "types", "entities"] { return "Data Models"; }
    if segment in ["orchestration", "workflows", "workflow"] { return "Orchestration"; }
    if segment in ["hooks", "hook", "composables"] { return "Hooks"; }
    if segment in ["graph", "graphs"] { return "Graph Engine"; }
    if segment in ["memory", "store", "stores", "state"] { return "State / Memory"; }
    if segment in ["utils", "util", "helpers", "lib", "shared", "common"] { return "Utilities"; }
    if segment in ["config", "configs", "configuration", "settings"] { return "Configuration"; }
    if segment in ["tests", "test", "__tests__", "spec", "specs"] { return "Tests"; }
    if segment in ["styles", "style", "css", "assets", "public", "static"] { return "Styles / Assets"; }
    if segment in ["middleware", "middlewares"] { return "Middleware"; }
    if segment in ["migrations", "migration", "db", "database"] { return "Database"; }
    if segment in ["docs", "doc", "documentation"] { return "Documentation"; }
    if segment in ["src"] { return "Source"; }
    if segment in ["app"] { return "Application"; }
    return segment;
}

def dir_area_team(label: str) -> str {
    if label in ["UI Components", "Pages / Views", "Styles / Assets", "Hooks"] { return "Client Team"; }
    if label in ["API Routes", "Controllers", "Services", "Middleware", "Database"] { return "Backend Team"; }
    if label in ["Agents", "Orchestration", "Graph Engine", "State / Memory"] { return "Core Team"; }
    if label in ["Data Models", "Configuration"] { return "Core Team"; }
    if label in ["Tests"] { return "QA Team"; }
    if label in ["Documentation"] { return "All Teams"; }
    if label in ["Utilities", "Source", "Application"] { return "Core Team"; }
    return "Core Team";
}

def dir_area_confidence(label: str) -> float {
    if label in ["API Routes", "Controllers"] { return 0.80; }
    if label in ["Agents", "Orchestration"] { return 0.78; }
    if label in ["Services"] { return 0.76; }
    if label in ["Graph Engine", "Source"] { return 0.75; }
    if label in ["UI Components"] { return 0.74; }
    if label in ["Pages / Views"] { return 0.73; }
    if label in ["Data Models"] { return 0.72; }
    if label in ["Hooks"] { return 0.70; }
    if label in ["State / Memory", "Middleware", "Database"] { return 0.68; }
    if label in ["Configuration"] { return 0.65; }
    if label in ["Styles / Assets"] { return 0.60; }
    if label in ["Tests"] { return 0.58; }
    return 0.50;
}

def path_area_key(file_path: str) -> str {
    parts: list[str] = file_path.split("/");
    if len(parts) >= 3 {
        seg0: str = parts[0].lower();
        seg1: str = parts[1].lower();
        if seg0 in ["src", "app", "lib"] {
            label: str = dir_area_label(seg1);
            if label != seg1 {
                return seg0 + "/" + seg1;
            }
        }
    }
    if len(parts) >= 2 {
        seg: str = parts[0].lower();
        label: str = dir_area_label(seg);
        if label != seg {
            return seg;
        }
    }
    return "";


}

def build_ownership(repo_summary_name: str, files: list[FileMatch]) -> list[OwnershipGuess] {
    ownership: list[OwnershipGuess] = [];
    seen_keys: list[str] = [];
    seen_labels: list[str] = [];

    for item in files {
        key: str = path_area_key(item.path);
        if not key or key in seen_keys {
            continue;
        }
        parts: list[str] = key.split("/");
        seg: str = parts[-1];
        label: str = dir_area_label(seg);
        if label in seen_labels {
            continue;
        }
        seen_keys.append(key);
        seen_labels.append(label);
        team: str = dir_area_team(label);
        conf: float = dir_area_confidence(label);
        ownership.append(OwnershipGuess(
            area=label,
            owner=team,
            confidence=conf,
            rationale="Inferred from files under " + key + "/ in " + repo_summary_name + "."
        ));
        if len(ownership) >= 5 {
            break;
        }
    }

    if len(ownership) == 0 and len(files) > 0 {
        ownership.append(OwnershipGuess(area="Project", owner="Core Team", confidence=0.50, rationale="Ownership inferred from top-level structure in " + repo_summary_name + "."));
    }

    return ownership;
}


def to_planning_insight(title: str, detail: str, severity: str, category: str) -> PlanningInsight {
    return PlanningInsight(title=title, detail=detail, severity=severity, category=category);
}


def build_planning(request: WorkflowRequest, files: list[FileMatch], blockers: list[BlockerItem], graph: ProjectContextGraph, meeting_summary: MeetingSummary) -> ExecutionPlanningContext {
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


def:pub run_workflow(repo_path: str, meeting_text: str, prompt: str, mode: str = "feature_plan") -> WorkflowResultBundle {
    try {
        return _run_workflow_impl(repo_path, meeting_text, prompt, mode);
    } except Exception as e {
        print("[RepoGhost] run_workflow error: " + str(e));
        print_exc();
        raise e;
    }
}

def _run_workflow_impl(repo_path: str, meeting_text: str, prompt: str, mode: str = "feature_plan") -> WorkflowResultBundle {
    request: WorkflowRequest = WorkflowRequest(repo_path=repo_path, meeting_text=meeting_text, prompt=prompt, mode=mode);
    bundle: WorkflowResultBundle = get_demo_bundle();

    repo_summary: RepoSummary = run_repo_mapper(request.repo_path);
    meeting_summary: MeetingSummary = run_meeting_interpreter(request.meeting_text);
    relevant_files: list[FileMatch] = run_code_search(request.repo_path, request.prompt, request.meeting_text);
    docs_context: WorkflowDocsContext = collect_workflow_docs(request.repo_path);
    doc_files: list[FileMatch] = docs_context.files;
    doc_decisions: list[DecisionItem] = docs_context.decisions;

    merged_files: list[FileMatch] = relevant_files + doc_files;
    merged_decisions: list[DecisionItem] = meeting_summary.decisions + doc_decisions;
    merged_blockers: list[BlockerItem] = meeting_summary.blockers;
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
    bundle.action_plan = build_action_plan(request, bundle.planning, merged_files);
    bundle.tasks = build_action_tasks(request, bundle.planning, merged_files, meeting_summary);
    bundle.tickets = write_tickets(request, bundle.planning, bundle.tasks, merged_files);
    bundle.standup = generate_standup(request, bundle.planning, bundle.tasks, bundle.trace, meeting_summary);
    bundle.handoff = generate_handoff(request, bundle.planning, bundle.tasks, merged_files);
    bundle.review = prepare_review_scope(request, bundle.planning, bundle.tasks, merged_files);
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
        bundle.action_plan.headline = "Current request: generate a standup update grounded in repo, meeting, graph, planning, and Stage 3 output context.";
    } elif request.mode == "handoff" {
        bundle.action_plan.headline = "Current request: prepare a handoff grounded in repo, meeting, graph, planning, and Stage 3 output context.";
    } elif request.mode == "review_prep" {
        bundle.action_plan.headline = "Current request: prepare review scope from live stage 1 outputs, Stage 2 reasoning, and Stage 3 review prep artifacts.";
    } elif request.mode == "meeting_to_tickets" {
        bundle.action_plan.headline = "Current request: turn meeting context into execution-ready tickets and next actions.";
    }

    remember_session(request, bundle);
    memory_snapshot: dict = update_project_memory(request.repo_path, bundle);
    updated_at = str(memory_snapshot["updated_at"]);
    bundle.review.checklist = bundle.review.checklist + ["Memory updated at " + updated_at];
    return bundle;
}


def:pub get_memory_snapshot(repo_path: str) -> dict {
    return get_project_memory(repo_path);
}
