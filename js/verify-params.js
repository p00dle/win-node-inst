const path = require("path");
const { exit } = require("./exit");
const { getToken } = require("./get-token");
exports.verifyParams = function verifyParams(
  params,
  packageJsonExists,
  deployExists
) {
  const files = packageJsonExists
    ? deployExists
      ? "neither package.json nor .deploy-installer"
      : "package.json"
    : ".deploy";

  if (!params.name) exit(`"name" not defined in ${files}`);
  if (!params.repo) exit(`"repo" not defined in ${files}`);
  if (!params.entry) exit(`"entry" not defined in ${files}`);
  if (!params.token) params.token = getToken();
  params.standalone = params.standalone !== "false";
  params.tsc = params.tsc === "true";
  params.entry = path
    .join(path.dirname(params.dir), params.entry)
    .replace(path.dirname(params.dir), "")
    .replace(/^[\\\/]+/, "");
  params.repo = params.repo.replace(/^git\+/, "");
  return params;
};
