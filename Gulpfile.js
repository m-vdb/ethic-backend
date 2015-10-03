require('coffee-script/register');
var gulp = require('gulp'),
    mocha = require('gulp-mocha');

gulp.task('test', function () {
  return gulp.src(['test/**/*.coffee'], {read: false})
    .pipe(mocha({reporter: 'nyan', require: ['./test/setup.js']}));
});