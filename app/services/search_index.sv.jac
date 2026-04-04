import from app.models.core { FileMatch }
include app.services.repo_ingest;

def split_terms(text: str) -> list[str] {
    return text.split(" ");
}

def term_score(lowered_path: str, terms: list[str]) -> float {
    score: float = 0.0;
    for term in terms {
        if len(term) >= 3 and term in lowered_path {
            score += 0.18;
        }
    }
    return score;
}

def path_score(lowered_path: str) -> float {
    if lowered_path.endswith(".sv.jac") {
        return 0.12;
    }
    if lowered_path.endswith(".cl.jac") {
        return 0.08;
    }
    if lowered_path.endswith("readme.md") {
        return 0.05;
    }
    return 0.0;
}

def score_file(path_text: str, prompt: str, meeting_text: str) -> float {
    lowered_path = path_text.lower();
    combined_text: str = prompt + " " + meeting_text;
    lowered_text: str = combined_text.lower();
    terms: list[str] = split_terms(lowered_text);
    return 0.1 + term_score(lowered_path, terms) + path_score(lowered_path);
}

def rationale_for(path_text: str, prompt: str, meeting_text: str) -> str {
    return "Ranked from path heuristics using " + str(len(split_terms(prompt))) + " prompt terms and " + str(len(split_terms(meeting_text))) + " meeting terms for: " + path_text;
}

def insert_ranked(ranked: list[FileMatch], candidate: FileMatch) -> list[FileMatch] {
    ordered: list[FileMatch] = [];
    inserted = False;
    for item in ranked {
        if not inserted and candidate.score > item.score {
            ordered.append(candidate);
            inserted = True;
        }
        ordered.append(item);
    }
    if not inserted {
        ordered.append(candidate);
    }
    return ordered;
}

def:pub search_repo(repo_path: str, prompt: str, meeting_text: str) -> list[FileMatch] {
    scanned: list[FileMatch] = scan_repo(repo_path);
    ranked: list[FileMatch] = [];
    for item in scanned {
        candidate: FileMatch = FileMatch(
            path=item.path,
            score=score_file(item.path, prompt, meeting_text),
            rationale=rationale_for(item.path, prompt, meeting_text),
            kind=item.kind
        );
        ranked = insert_ranked(ranked, candidate);
    }
    if len(ranked) > 12 {
        return ranked[:12];
    }
    return ranked;
}
