const { readFile } = require('./file');

exports.parsePackageJson = function parsePackageJson(packageJsonPath) {
  let output = {}
  let json;
  try {
    json = JSON.parse(readFile(packageJsonPath));
  } catch {
    return output;
  }
  if (json.name) output.name = json.name;
  if (json.repository && json.repository.type === 'git' && json.repository.url) output.repo = json.repository.url;
  if (json.main) output.entry = json.main;
  return output;
}
