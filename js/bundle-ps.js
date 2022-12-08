const path = require("path");
const { readFile } = require("./file");

exports.bundlePs = function bundlePs(filePath) {
  const fileDir = path.dirname(filePath);
  const fileContent = readFile(filePath);
  const fileLines = fileContent.split(/\r*\n/);
  return fileLines
    .map((line) => {
      if (!/^\.\s+.+$/.test(line)) return line;
      const modulePath = line.replace(/^\.\s+/, "").replace(/\s+$/, "");
      const moduleAbsolutePath = path.isAbsolute(modulePath)
        ? modulePath
        : path.join(fileDir, modulePath);
      return (
        `# IMPORT ${modulePath}\n` +
        bundlePs(moduleAbsolutePath) +
        `\n# END-IMPORT ${modulePath}\n`
      );
    })
    .join("\n");
};
