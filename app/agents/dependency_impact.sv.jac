import from app.models.core { FileMatch }
import from app.models.workflow { WorkflowRequest }
import from app.models.outputs { ProjectContextGraph }

obj ImpactInsight {
    has area: str = "";
    has detail: str = "";
    has risk: str = "medium";
}

def impact_risk(path: str) -> str {
    if path.startswith("app/orchestration") or path.startswith("app/graph") {
        return "high";
    }
    if path.startswith("app/components") {
        return "medium";
    }
    return "low";
}

def:pub analyze_dependency_impact(request: WorkflowRequest, files: list[FileMatch], graph: ProjectContextGraph) -> list[ImpactInsight] {
    impacts: list[ImpactInsight] = [];
    for item in files[:6] {
        detail = "Changes touching " + item.path + " likely ripple into workflow orchestration, UI panels, or graph-backed outputs.";
        impacts.append(ImpactInsight(area=item.path, detail=detail, risk=impact_risk(item.path)));
    }
    if len(graph.edges) > 12 {
        impacts.append(ImpactInsight(area="context graph relationships", detail="Dense graph relationships suggest downstream updates across blockers, tickets, and review scope views.", risk="high"));
    }
    if request.mode == "review_prep" {
        impacts.append(ImpactInsight(area="review workflow", detail="Review prep mode should validate changed areas, risk hotspots, and reviewer checklist generation together.", risk="medium"));
    }
    return impacts;
}
