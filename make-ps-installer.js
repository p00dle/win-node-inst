#!/usr/bin/env node
const path = require('path');
const { exit } = require('./js/exit');
const { writeFile, createDirIfNotExists } = require('./js/file');
const { parseDeploy } = require('./js/parse-deploy');
const { parsePackageJson } = require('./js/parse-package');
const { getPaths } = require('./js/get-paths');
const { verifyParams } = require('./js/verify-params');
const { bundlePs } = require('./js/bundle-ps');
const [packageJsonPath, deployPath, packageJsonExists, deployExists] = getPaths();

let params = { dir: path.dirname(packageJsonPath) };
if (!packageJsonExists && !deployExists) exit(`Could not locate package.json nor .deploy-installer at path: ${path.dirname(packageJsonPath)}`);
if (packageJsonExists) params = { ...params, ...parsePackageJson(packageJsonPath) };
if (deployExists) params = { ...params, ...parseDeploy(deployPath) };
params = verifyParams(params, packageJsonExists, deployExists);
const installerParams = `
$appName = "${params.name}"
$appEntryPoint = "${params.entry}"
$gitAccessToken = ${params.token ? `"${params.token}"` : '$null'}
$standalone = ${params.standalone ? '$true' : '$false'}
$mainGitRepository = "${params.repo}"
$useTsc = ${params.tsc ? '$true' : '$false'}
`;
const installerName = `${params.name}-installer.ps1`;
createDirIfNotExists(path.join(path.dirname(packageJsonPath), 'win-install'))
writeFile(path.join(path.dirname(packageJsonPath), 'win-install', installerName), installerParams + bundlePs(path.join(__dirname, 'main.ps1')));
exit();

