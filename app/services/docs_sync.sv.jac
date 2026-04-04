import from os { path }
import from app.models.core { DecisionItem, FileMatch }
import from app.models.outputs { DocsSyncResult }

def read_text(file_path: str) -> str {
    try {
        with open(file_path, "r", encoding="utf-8") as handle {
            return handle.read();
        }
    } except OSError {
        return "";
    } except UnicodeError {
        return "";
    }
}

def split_lines(text: str) -> list[str] {
    return text.split("\n");
}

def trim_text(text: str) -> str {
    return text.strip();
}

def:pub sync_docs(repo_path: str) -> DocsSyncResult {
    docs: list[FileMatch] = [];
    decisions: list[DecisionItem] = [];
    if not repo_path {
        return DocsSyncResult(files=docs, decisions=decisions);
    }
    candidates = ["README.md", "readme.md", "docs/README.md", "SPEC.md", "docs/spec.md"];
    for rel_path in candidates {
        full_path = path.join(repo_path, rel_path.replace("/", path.sep));
        if path.exists(full_path) {
            content = read_text(full_path);
            docs.append(
                FileMatch(
                    path=rel_path,
                    score=0.76,
                    rationale="Documentation file pulled into project context.",
                    kind="doc"
                )
            );
            if content {
                non_empty_lines: list[str] = [];
                content_lines: list[str] = split_lines(content);
                for line in content_lines {
                    stripped: str = trim_text(line);
                    if stripped {
                        non_empty_lines.append(stripped);
                    }
                }
                if len(non_empty_lines) > 0 {
                    decisions.append(
                        DecisionItem(
                            title="Doc summary",
                            detail=non_empty_lines[0],
                            confidence=0.61,
                            source=rel_path
                        )
                    );
                }
            }
        }
    }
    return DocsSyncResult(files=docs, decisions=decisions);
}
