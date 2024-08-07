'use strict'

const eslint = require('gulp-eslint')
const vfs = require('vinyl-fs')

module.exports = (files) => (done) =>
  vfs
    .src(files)
    .pipe(eslint({fix:true}))
    .pipe(eslint.format())
    .pipe(eslint.failAfterError())
    .on('error', done)
