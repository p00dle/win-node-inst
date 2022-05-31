const fs = require('fs');

exports.readFile = function readFile(filePath) {
  return fs.readFileSync(filePath, { encoding: 'utf8' });
}

exports.exists = function exists(filePath) {
  try {
    fs.accessSync(filePath);
    return true;
  } catch {
    return false;
  }
}

exports.writeFile = function writeFile(filePath, data) {
  fs.writeFileSync(filePath, data);
}

