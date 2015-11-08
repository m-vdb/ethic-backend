require('coffee-script/register');
var gulp = require('gulp'),
    mocha = require('gulp-mocha'),
    rename = require('gulp-rename'),
    pathExists = require('path-exists');

var ENV_FILE_TPL = '.env.tpl',
    ENV_FILE = '.env';

gulp.task('test', function () {
  return gulp.src(['test/**/*.coffee'], {read: false})
    .pipe(mocha({reporter: 'spec', require: ['./test/setup.js']}))
    .once('end', function () {
      process.exit();
    });
});

gulp.task('postinstall', function () {
  pathExists(ENV_FILE).then(function (exists) {
    if (exists) return;

    gulp.src(ENV_FILE_TPL)
      .pipe(rename(ENV_FILE))
      .pipe(gulp.dest('.'));
  });
});
