import from ..models.outputs { RepoSummary }
import from ..services.repo_ingest { summarize_repo }

def:pub run_repo_mapper(repo_path: str) -> RepoSummary {
    return summarize_repo(repo_path);
}
