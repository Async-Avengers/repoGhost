import from ..models.core { FileMatch, MeetingSummary }
import from ..models.workflow { WorkflowRequest }

obj TestGapInsight {
    has area: str = "";
    has recommendation: str = "";
    has test_type: str = "unit";
    has risk: str = "medium";
}

def:pub identify_test_gaps(request: WorkflowRequest, meeting: MeetingSummary, files: list[FileMatch]) -> list[TestGapInsight] {
    gaps: list[TestGapInsight] = [];
    for item in files[:6] {
        test_type = "unit";
        if item.path.startswith("app/orchestration") or item.path.startswith("app/services") {
            test_type = "integration";
        }
        if item.path.startswith("app/components") or item.path.startswith("app/hooks") {
            test_type = "e2e";
        }
        gaps.append(TestGapInsight(
            area=item.path,
            recommendation="Add " + test_type + " coverage for the request path touching " + item.path + ".",
            test_type=test_type,
            risk=("high" if item.score > 0.8 else "medium")
        ));
    }
    if len(meeting.action_items) > 2 {
        gaps.append(TestGapInsight(area="meeting parsing", recommendation="Add parser coverage for multi-action meeting notes, deadlines, and uncertainty extraction.", test_type="unit", risk="medium"));
    }
    if request.mode in ["handoff", "standup", "review_prep"] {
        gaps.append(TestGapInsight(area="artifact generation", recommendation="Add integration coverage for mode-specific output shaping and fallback behavior.", test_type="integration", risk="medium"));
    }
    return gaps;
}
