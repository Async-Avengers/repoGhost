import from ..models.core { MeetingSummary, DecisionItem, BlockerItem }

def collect_lines(text: str) -> list[str] {
    return [line.strip() for line in text.split("\n") if line.strip()];
}

def:pub parse_meeting(meeting_text: str) -> MeetingSummary {
    if not meeting_text {
        return MeetingSummary(summary="No meeting context provided.");
    }
    lines = collect_lines(meeting_text);
    action_items: list[str] = [];
    decisions: list[DecisionItem] = [];
    blockers: list[BlockerItem] = [];
    people: list[str] = [];
    systems: list[str] = [];
    deadlines: list[str] = [];
    uncertainty: list[str] = [];
    for line in lines {
        lowered = line.lower();
        if "todo" in lowered or "action" in lowered or "next" in lowered or "should" in lowered {
            action_items.append(line);
        }
        if "decide" in lowered or "decision" in lowered or "agreed" in lowered {
            decisions.append(DecisionItem(title="Meeting decision", detail=line, confidence=0.72, source="meeting"));
        }
        if "blocker" in lowered or "blocked" in lowered or "risk" in lowered or "waiting" in lowered {
            blockers.append(BlockerItem(title="Meeting blocker", detail=line, severity="medium", owner_hint="meeting"));
        }
        if "by friday" in lowered or "deadline" in lowered or "due" in lowered {
            deadlines.append(line);
        }
        if "maybe" in lowered or "unclear" in lowered or "not sure" in lowered {
            uncertainty.append(line);
        }
        if "api" in lowered or "ui" in lowered or "repo" in lowered or "workflow" in lowered or "memory" in lowered {
            systems.append(line);
        }
    }
    words = meeting_text.replace(",", " ").replace(".", " ").split();
    for word in words {
        if len(word) > 1 and word[0].isupper() and word not in people and word.lower() not in ["we", "the", "repo", "workflow"] {
            people.append(word);
        }
    }
    if len(action_items) == 0 {
        action_items = lines[:3];
    }
    return MeetingSummary(summary=lines[0], action_items=action_items, decisions=decisions, blockers=blockers, people=people[:8], systems=systems[:8], deadlines=deadlines, uncertainty=uncertainty);
}
