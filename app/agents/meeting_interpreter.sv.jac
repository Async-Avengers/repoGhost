import from ..models.core { MeetingSummary }
import from ..services.meeting_parse { parse_meeting }

def:pub run_meeting_interpreter(meeting_text: str) -> MeetingSummary {
    return parse_meeting(meeting_text);
}
