import from ..models.core { FileMatch }
import from ..models.workflow { WorkflowRequest }
import from ..graph.builder { ProjectContextGraph }

obj ImpactInsight {
    has area: str = "";
    has detail: str = "";
    has risk: str = "medium";
}

def:pub analyze_dependency_impact(request: WorkflowRequest, files: list[FileMatch], graph: ProjectContextGraph) -> list[ImpactInsight] {
    impacts: list[ImpactInsight] = [];
    for item in files[:6] {
        detail = "Changes touching " + item.path + " likely ripple into workflow orchestration, UI panels, or graph-backed outputs.";
        risk = "medium";
        if item.path.startswith("app/orchestration") or item.path.startswith("app/graph") {
            risk = "high";
        } elif item.path.startswith("app/components") {
            risk = "medium";
        } else {
            risk = "low";
        }
        impacts.append(ImpactInsight(area=item.path, detail=detail, risk=risk));
    }
    if len(graph.edges) > 12 {
        impacts.append(ImpactInsight(area="context graph relationships", detail="Dense graph relationships suggest downstream updates across blockers, tickets, and review scope views.", risk="high"));
    }
    if request.mode == "review_prep" {
        impacts.append(ImpactInsight(area="review workflow", detail="Review prep mode should validate changed areas, risk hotspots, and reviewer checklist generation together.", risk="medium"));
    }
    return impacts;
}
