import from ..models.core { BlockerItem, MeetingSummary, FileMatch }
import from ..models.workflow { WorkflowRequest }
import from ..graph.builder { ProjectContextGraph }

obj BlockerInsight {
    has title: str = "";
    has detail: str = "";
    has severity: str = "medium";
    has impacted_area: str = "";
}

def:pub detect_blockers(request: WorkflowRequest, meeting: MeetingSummary, files: list[FileMatch], graph: ProjectContextGraph) -> list[BlockerInsight] {
    insights: list[BlockerInsight] = [];
    if len(meeting.blockers) > 0 {
        for item in meeting.blockers[:5] {
            insights.append(BlockerInsight(title=item.title, detail=item.detail, severity=item.severity, impacted_area="meeting context"));
        }
    }
    if not request.repo_path {
        insights.append(BlockerInsight(title="Missing permitted repo path", detail="RepoGhost cannot ground reasoning without a selected local repository.", severity="high", impacted_area="repo ingestion"));
    }
    if len(files) == 0 {
        insights.append(BlockerInsight(title="Low code grounding", detail="No relevant files were ranked for the current request, so downstream planning confidence is reduced.", severity="high", impacted_area="code search"));
    }
    if len(graph.focus_paths) < 2 {
        insights.append(BlockerInsight(title="Thin context graph", detail="The unified project context graph has too few focus paths to support confident execution planning.", severity="medium", impacted_area="context graph"));
    }
    if "api" in request.meeting_text.lower() and "contract" not in request.meeting_text.lower() {
        insights.append(BlockerInsight(title="Missing API contract detail", detail="Meeting context references API work without a clear contract, schema, or payload definition.", severity="medium", impacted_area="integration design"));
    }
    return insights;
}
