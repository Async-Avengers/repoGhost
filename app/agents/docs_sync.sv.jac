import from ..models.core { DecisionItem, FileMatch }
import from ..services.docs_sync { sync_docs }

def:pub run_docs_sync(repo_path: str) -> tuple[list[FileMatch], list[DecisionItem]] {
    return sync_docs(repo_path);
}
