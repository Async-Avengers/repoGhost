import from os { path, walk }
import from app.models.outputs { RepoSummary }
import from app.models.core { FileMatch }

glob IGNORE_DIRS: list[str] = [
    ".git", ".jac", ".jaseci", "node_modules", "dist", "build", ".vite", "venv", ".venv", "__pycache__"
];

def should_skip_dir(name: str) -> bool {
    return name in IGNORE_DIRS or name.startswith(".") and name not in [".github"];
}

def should_include_file(name: str) -> bool {
    lowered = name.lower();
    exts = [".jac", ".cl.jac", ".sv.jac", ".md", ".txt", ".json", ".toml", ".yaml", ".yml", ".py", ".ts", ".tsx", ".js", ".jsx"];
    for ext in exts {
        if lowered.endswith(ext) {
            return True;
        }
    }
    return lowered in ["readme", "readme.md", "package.json", "jac.toml"];
}

def scored_match(rel_path: str, file_name: str) -> FileMatch {
    if file_name == "main.jac" {
        return FileMatch(path=rel_path, score=0.98, rationale="Primary Jac entry point.", kind="file");
    }
    if file_name.endswith(".sv.jac") {
        return FileMatch(path=rel_path, score=0.82, rationale="Server workflow or service module.", kind="file");
    }
    if file_name.endswith(".cl.jac") {
        return FileMatch(path=rel_path, score=0.74, rationale="Client UI or hook module.", kind="file");
    }
    if file_name.lower().startswith("readme") {
        return FileMatch(path=rel_path, score=0.68, rationale="Project documentation entry point.", kind="file");
    }
    return FileMatch(path=rel_path, score=0.35, rationale="Included from recursive repo scan.", kind="file");
}

def:pub scan_repo(repo_path: str) -> list[FileMatch] {
    matches: list[FileMatch] = [];
    if not repo_path or not path.exists(repo_path) {
        return matches;
    }
    for (current_root, dirs, files) in walk(repo_path) {
        kept_dirs: list[str] = [];
        for dir_name in dirs {
            if not should_skip_dir(dir_name) {
                kept_dirs.append(dir_name);
            }
        }
        dirs.clear();
        for dir_name in kept_dirs {
            dirs.append(dir_name);
        }
        for file_name in files {
            if not should_include_file(file_name) {
                continue;
            }
            full_path = path.join(current_root, file_name);
            rel_path: str = str(path.relpath(full_path, repo_path)).replace("\\", "/");
            matches.append(scored_match(rel_path, file_name));
        }
    }
    return matches;
}

def:pub summarize_repo(repo_path: str) -> RepoSummary {
    files = scan_repo(repo_path);
    project_name = path.basename(repo_path) if repo_path else "RepoGhost";
    major_dirs: list[str] = [];
    entry_points: list[str] = [];
    frameworks: list[str] = ["Jac"];
    for item in files {
        parts: list[str] = item.path.split("/");
        if len(parts) > 1 and parts[0] not in major_dirs {
            major_dirs.append(parts[0]);
        }
        if item.path in ["main.jac", "jac.toml"] {
            entry_points.append(item.path);
        }
        lowered = item.path.lower();
        if lowered.endswith(".cl.jac") and "jac-client" not in frameworks {
            frameworks.append("jac-client");
        }
        if lowered.endswith(".css") and "Tailwind" not in frameworks {
            frameworks.append("Tailwind");
        }
    }
    overview = "Repo scan found " + str(len(files)) + " relevant files for project context mapping.";
    return RepoSummary(project_name=project_name, overview=overview, frameworks=frameworks, entry_points=entry_points, major_dirs=major_dirs);
}
