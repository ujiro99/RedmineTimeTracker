'use strict';
var gulp = require('gulp');
var replace = require('gulp-replace');
var path = require('path');

var constant = {
    cwd: process.env.INIT_CWD || '',
    nsiTemplate: './src/nsi-template/include/',
    fileAssociation: {
        extension: '.myapp',
        fileType: 'My Awesome App File'
    }
};

// task to generate nsi-template for windows
gulp.task('nsi-template', function () {
    var projectIncludeDir = path.join(constant.cwd, constant.nsiTemplate);
    return gulp.src('src/nsi-template/installer.nsi.tpl')
        .pipe(replace('@projectIncludeDir', projectIncludeDir))
        .pipe(replace('@projectExtension', constant.fileAssociation.extension))
        .pipe(replace('@projectFileType', constant.fileAssociation.fileType))
        .pipe(gulp.dest('release/electron/nsi-template/win'));
});
