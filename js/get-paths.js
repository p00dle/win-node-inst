const path = require("path");
const { exists } = require("./file");
exports.getPaths = function getPaths() {
  let packageJsonPath = path.join(process.cwd(), "package.json");
  let argPath = process.argv[2];
  if (argPath) {
    if (!path.isAbsolute(argPath)) {
      argPath = path.join(process.cwd(), argPath);
    }
    if (!argPath.includes("package.json")) {
      argPath = path.join(argPath, "package.json");
    }
    packageJsonPath = argPath;
  }
  let deployPath = path.join(
    path.dirname(packageJsonPath),
    ".deploy-installer"
  );
  return [
    packageJsonPath,
    deployPath,
    exists(packageJsonPath),
    exists(deployPath),
  ];
};
