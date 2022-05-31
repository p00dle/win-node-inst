
const gitIgnorePath = packageJsonPath.replace('package.json', '.gitignore');
const installerName = `${packageJson.name}-installer.ps1`;
try {
  const gitIgnoreContent = readFile(gitIgnorePath);
  if (!gitIgnoreContent.includes(installerName)) {
    fs.writeFileSync(gitIgnorePath, gitIgnoreContent.replace(/\s*$/, `\n${installerName}\n`));
  }
} catch {
  console.warn('Could not update .gitignore file');
}
