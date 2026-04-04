import "../../styles/global.css";
import from app.components.AppShell { AppShell }

def:pub Layout() -> JsxElement {
    return <div className="dark min-h-screen bg-background text-foreground">
        <AppShell />
    </div>;
}
