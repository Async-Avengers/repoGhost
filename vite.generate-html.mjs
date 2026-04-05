import fs from "fs";
import path from "path";

/**
 * Vite plugin that writes dist/index.html after each production build.
 *
 * Jac's vite config uses a JS entry point (compiled/_entry.js) rather than
 * an HTML file, so Vite never emits index.html on its own. Tauri requires
 * index.html to be present in frontendDist, so we generate it here by
 * scanning the dist directory for the hashed bundle and the fixed CSS file.
 */
export default function generateHtmlPlugin(buildDir) {
  return {
    name: "repoghost-generate-html",
    apply: "build",
    closeBundle() {
      const distDir = path.resolve(buildDir, "dist");

      let jsFile = null;
      try {
        const files = fs.readdirSync(distDir);
        jsFile = files.find(
          (f) => f.startsWith("client.") && f.endsWith(".js") && !f.endsWith(".map")
        );
      } catch (e) {
        console.warn("[repoghost] Could not read dist directory:", e.message);
        return;
      }

      if (!jsFile) {
        console.warn("[repoghost] No client bundle found in dist/ — index.html not generated.");
        return;
      }

      const html = `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>repoGhost</title>
    <link rel="stylesheet" href="/styles.css" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/${jsFile}"></script>
  </body>
</html>
`;

      const htmlPath = path.resolve(distDir, "index.html");
      fs.writeFileSync(htmlPath, html, "utf-8");
      console.log("[repoghost] Generated", htmlPath);
    },
  };
}
