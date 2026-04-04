import from app.orchestration.workflow { run_workflow, get_memory_snapshot }
import from app.services.demo_data { get_demo_bundle }
import from app.services.repo_ingest { scan_repo, summarize_repo }
import from app.services.search_index { search_repo }
import from app.services.meeting_parse { parse_meeting }
import from app.services.docs_sync { sync_docs }
import from app.services.memory_store { recent_session_runs, get_project_memory }
cl import from app.components.Layout { Layout }

cl {
    def:pub app() -> JsxElement {
        return <Layout />;
    }
}
