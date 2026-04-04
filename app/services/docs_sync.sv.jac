import from os import path
import from ..models.core { DecisionItem, FileMatch }

def read_text(file_path: str) -> str {
    try {
        with open(file_path, "r", encoding="utf-8") as handle {
            return handle.read();
        }
    } except Exception {
        return "";
    }
}

def:pub sync_docs(repo_path: str) -> tuple[list[FileMatch], list[DecisionItem]] {
    docs: list[FileMatch] = [];
    decisions: list[DecisionItem] = [];
    if not repo_path {
        return (docs, decisions);
    }
    candidates = ["README.md", "readme.md", "docs/README.md", "SPEC.md", "docs/spec.md"];
    for rel_path in candidates {
        full_path = path.join(repo_path, rel_path.replace("/", path.sep));
        if path.exists(full_path) {
            content = read_text(full_path);
            docs.append(FileMatch(path=rel_path, score=0.76, rationale="Documentation file pulled into project context.", kind="doc"));
            if content {
                first_line = [line.strip() for line in content.split("\n") if line.strip()];
                if len(first_line) > 0 {
                    decisions.append(DecisionItem(title="Doc summary", detail=first_line[0], confidence=0.61, source=rel_path));
                }
            }
    }
    return (docs, decisions);
}
