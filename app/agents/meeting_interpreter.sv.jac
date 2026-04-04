import from app.models.core { MeetingSummary }
include app.services.meeting_parse;

def:pub run_meeting_interpreter(meeting_text: str) -> MeetingSummary {
    return parse_meeting(meeting_text);
}
