exports.exit = function exit(error) {
  if (error) {
    console.error(error);
    process.exit(1);
  } else {
    console.info('Done');
    process.exit(0);
  }
}