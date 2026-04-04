import from ..models.core { FileMatch }
import from ..services.search_index { search_repo }

def:pub run_code_search(repo_path: str, prompt: str, meeting_text: str) -> list[FileMatch] {
    return search_repo(repo_path, prompt, meeting_text);
}
