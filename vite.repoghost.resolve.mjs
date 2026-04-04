import path from "path";

export default function repoghostClientResolve(buildDir) {
  const projectRoot = path.resolve(buildDir, "..", "..");
  return {
    name: "repoghost-client-resolve",
    enforce: "pre",
    resolveId(source) {
      if (source === "typing") {
        return path.resolve(projectRoot, "typing.repoghost.js");
      }
      if (source.startsWith("./app/")) {
        return path.resolve(buildDir, "compiled", source.slice(2));
      }
      return null;
    },
  };
}
