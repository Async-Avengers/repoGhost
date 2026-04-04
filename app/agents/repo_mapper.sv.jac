import from app.models.outputs { RepoSummary }
include app.services.repo_ingest;

def:pub run_repo_mapper(repo_path: str) -> RepoSummary {
    return summarize_repo(repo_path);
}
