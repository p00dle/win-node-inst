const { readFile } = require("./file");

exports.parseDeploy = function parseDeploy(deployPath) {
  const content = readFile(deployPath).trim();
  const lines = content.split(/\r*\n/);
  const output = {};
  for (const [key, value] of lines.map((line) => line.split("="))) {
    output[key.trim()] = value.trim();
  }
  return output;
};
