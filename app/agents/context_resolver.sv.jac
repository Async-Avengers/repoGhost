import from ..models.core { FileMatch }
import from ..models.workflow { WorkflowRequest }
import from ..graph.builder { ProjectContextGraph }

obj ResolvedArea {
    has phrase: str = "";
    has target: str = "";
    has rationale: str = "";
    has confidence: float = 0.0;
}

def normalize_terms(text: str) -> list[str] {
    cleaned = text.lower();
    for token in [",", ".", ":", ";", "(", ")", "[", "]", "{", "}", "\n", "\r", "\t", "?", "!"] {
        cleaned = cleaned.replace(token, " ");
    }
    terms: list[str] = [];
    for part in cleaned.split(" ") {
        item = part.strip();
        if item and len(item) > 2 and item not in terms {
            terms.append(item);
        }
    }
    return terms;
}

def score_match(terms: list[str], path: str, rationale: str) -> float {
    score = 0.0;
    haystack = (path + " " + rationale).lower();
    for term in terms {
        if term in haystack {
            score += 0.18;
        }
    }
    if path.startswith("app/components") {
        score += 0.08;
    }
    if path.startswith("app/services") or path.startswith("app/orchestration") {
        score += 0.12;
    }
    return score;
}

def:pub resolve_context(request: WorkflowRequest, files: list[FileMatch], graph: ProjectContextGraph) -> list[ResolvedArea] {
    terms = normalize_terms(request.prompt + " " + request.meeting_text + " " + request.mode);
    resolved: list[ResolvedArea] = [];
    for item in files[:10] {
        score = score_match(terms, item.path, item.rationale);
        if score > 0.16 {
            resolved.append(ResolvedArea(
                phrase=request.prompt,
                target=item.path,
                rationale="Matched request and meeting language against ranked repo paths and graph focus areas.",
                confidence=score
            ));
        }
    }
    if len(resolved) == 0 {
        for item in graph.focus_paths[:4] {
            resolved.append(ResolvedArea(
                phrase=request.prompt,
                target=item,
                rationale="Fallback to graph focus path because direct lexical resolution was weak.",
                confidence=0.34
            ));
        }
    }
    return resolved;
}
