exports.getToken = function getToken() {
  if (process.env.GIT_INSTALLER_ACCESS_TOKEN) {
    return process.env.GIT_INSTALLER_ACCESS_TOKEN;
  } else {
    console.warn('Token not specified in neither env variable GIT_INSTALLER_ACCESS_TOKEN nor in .deploy-installer');
    console.warn('If main repo or any of the dependencies are private build will fail');
    return null;
  }
}