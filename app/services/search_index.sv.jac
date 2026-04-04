import from ..models.core { FileMatch }
import from .repo_ingest { scan_repo }

def score_file(path_text: str, prompt: str, meeting_text: str) -> float {
    score = 0.1;
    lowered_path = path_text.lower();
    terms = (prompt + " " + meeting_text).lower().split();
    for term in terms {
        if len(term) < 3 {
            continue;
        }
        if term in lowered_path {
            score += 0.18;
        }
    }
    if lowered_path.endswith(".sv.jac") {
        score += 0.12;
    }
    if lowered_path.endswith(".cl.jac") {
        score += 0.08;
    }
    if lowered_path.endswith("readme.md") {
        score += 0.05;
    }
    return score;
}

def rationale_for(path_text: str, prompt: str, meeting_text: str) -> str {
    return "Ranked from path heuristics using prompt and meeting terms for: " + path_text;
}

def:pub search_repo(repo_path: str, prompt: str, meeting_text: str) -> list[FileMatch] {
    scanned = scan_repo(repo_path);
    ranked: list[FileMatch] = [];
    for item in scanned {
        ranked.append(FileMatch(path=item.path, score=score_file(item.path, prompt, meeting_text), rationale=rationale_for(item.path, prompt, meeting_text), kind=item.kind));
    }
    ranked.sort(key=lambda item: item.score, reverse=True);
    if len(ranked) > 12 {
        return ranked[:12];
    }
    return ranked;
}
