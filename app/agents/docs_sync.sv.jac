import from app.models.outputs { DocsSyncResult }
include app.services.docs_sync;

def:pub run_docs_sync(repo_path: str) -> DocsSyncResult {
    return sync_docs(repo_path);
}
