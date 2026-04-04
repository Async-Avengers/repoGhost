import from app.models.core { FileMatch }
include app.services.search_index;

def:pub run_code_search(repo_path: str, prompt: str, meeting_text: str) -> list[FileMatch] {
    matches: list[FileMatch] = search_repo(repo_path, prompt, meeting_text);
    return matches;
}
