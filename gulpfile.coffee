###
Requires
###
fs = require 'fs'

gulp            = require 'gulp'
gulpsync        = require('gulp-sync')(gulp)

gutil           = require 'gulp-util'
clean           = require "gulp-clean"
zip             = require 'gulp-zip'

mocha           = require 'gulp-mocha'

CronJob         = require('cron').CronJob
colors          = require 'colors'

coffee          = require 'gulp-coffee'
cson            = require 'gulp-cson'

jsdoc           = require "gulp-jsdoc"

sass            = require 'gulp-sass'
cssshrink       = require 'gulp-cssshrink'
autoprefixer    = require 'gulp-autoprefixer'
insert          = require 'gulp-insert'
browserify      = require 'gulp-browserify'
uglify          = require 'gulp-uglify'
rename          = require 'gulp-rename'

###
=====================================
Пути
=====================================
###

# Папки где находится проект
folders = 
    development:    'development'
    production:     'bin'

    assets:
        public:     "public"
        private:    "private"
        templates:  "templates"

    docs:           'docs'
    backup:         'backup'
    release:        'release'

times =
    backup: 10

# Пути до задач
paths =
    # Клиентские файлы
    client:
        # Sass / Scss
        scss:
            from: [
                "./#{folders.development}/#{folders.assets.private}/scss/**/*.scss"
                "!./#{folders.development}/#{folders.assets.private}/scss/**/^_*.scss"
            ]
            to:     "./#{folders.production}/#{folders.assets.public}/css/"
            suffix: ""

        # Coffee
        coffee:
            from: [
                "./#{folders.development}/#{folders.assets.private}/coffee/**/*.coffee"
                "!./#{folders.development}/#{folders.assets.private}/coffee/**/^_*.coffee"
            ]
            to:     "./#{folders.production}/#{folders.assets.public}/js/"
            suffix: ".min"

        # JavaScript
        js:
            from: [
                "./#{folders.development}/#{folders.assets.private}/js/**/*.js"
                "!./#{folders.development}/#{folders.assets.private}/js/**/^_*.js"
                "!./#{folders.production}/**/*.js"
            ]
            to:     "./#{folders.production}/#{folders.assets.public}/js/"
            suffix: ".min"

        # Копирование
        copy:
            from: [
                "./#{folders.development}/#{folders.assets.private}/copy/**/*"
            ]
            to:     "./#{folders.production}/#{folders.assets.public}/"
            suffix: ""

        # Шаблоны
        templates:
            from: [
                "./#{folders.development}/#{folders.assets.templates}/**/*"
            ]
            to: "./#{folders.production}/#{folders.assets.templates}/"

    # Серверные файлы
    server:
        coffee:
            from: [
                "./#{folders.development}/**/*.coffee"
                "!./#{folders.development}/#{folders.assets.private}/**/*"
            ]
            to:     "./#{folders.production}/"

        cson:
            from: [
                "./#{folders.development}/**/*.cson"
                "!./#{folders.development}/#{folders.assets.private}/**/*"
            ]
            to:     "./#{folders.production}/"

    # Остальное
    general:
        # Документация
        jsdoc:
            from: [
                "./#{folders.production}/**/*.js"
                "!./#{folders.production}/node_modules/**/*.js"
            ]
            to: "./#{folders.docs}/"
        # Бэкапы
        backup:
            from: [
                "./#{folders.development}/**/*"
                "./#{folders.release}/**/*"
                "./*.*"
                "!./"
                "!./#{folders.docs}/**/*"
                "!./#{folders.backup}/**/*"
                "!./#{folders.production}/**/*"
            ]
            to: "./#{folders.backup}/"
        # Релизы
        release:
            from: [
                "./#{folders.production}/**/*"
                "./*.{json,js,yml,md,txt}"
                "!./"
                "!./#{folders.development}/**/*"
                "!./#{folders.docs}/**/*"
                "!./#{folders.backup}/**/*"
                "!./#{folders.release}/**/*"
            ]
            to: "./#{folders.release}/"
        # Очистка предыдущей сборки
        clean:
            from: [
                "./#{folders.production}/**/*"
            ]
        # Тестирование
        test:
            from: [
                "./#{folders.production}/test/**/test*.js"
            ]

###
=====================================
Функции
=====================================
###

###*
 * Обработчик ошибок
 * @param  {Error} err - ошибка
###
error = (err)->
    console.log err.message
    @.emit 'end'

###*
 * Получение версии пакета
 * @param  {String} placeholder - строка которая заменит версию пакета, если JSON файл поврежден
 * @return {String}             - версия пакета
###
getPackageVersion = (placeholder)->
    try
        packageFile = fs.readFileSync("./package.json").toString()
        packageFile = JSON.parse packageFile

        if packageFile?.version?
            version = "v#{packageFile.version}"
        else
            version = null
    catch e
        error e
        version = null

    if !version and placeholder
        version = "#{placeholder}"
    else if !version
        version = "v0.0.0"

    return version

###*
 * Преобразует минуты в cron
 * @param  {Number} min - период бекаров
 * @return {String}     - cron date
###
getCronTime = (min)->
    return "0 */#{min} * * * *"

###
=====================================
Задачи
=====================================
###
###
-------------------------------------
Клиент
-------------------------------------
###
# SCSS
gulp.task 'client:scss', (next)->
    gulp.src paths.client.scss.from
        # Рендер Sass
        .pipe sass({outputStyle: 'compressed'}).on 'error', error
        # Добавление префиксов
        .pipe autoprefixer {
            browsers: ['last 100 version']
        }
        # Минификация
        .pipe cssshrink()
        # Переименование
        .pipe rename {
            suffix: paths.client.scss.suffix
        }
        # Сохранение
        .pipe gulp.dest paths.client.scss.to
        .on 'error', error
        .on 'finish', next

    return

# Coffee
gulp.task 'client:coffee', (next)->
    gulp.src paths.client.coffee.from
        # Рендер Coffee
        .pipe coffee({bare: true}).on 'error', error
        # Минификация
        .pipe uglify()
        # Переименование
        .pipe rename {
            suffix: paths.client.coffee.suffix
        }
        # Сохранение
        .pipe gulp.dest paths.client.coffee.to
        .on 'error', error
        .on 'finish', next
        
    return

# JS
gulp.task 'client:js', (next)->
    gulp.src paths.client.js.from
        # Минификация
        .pipe uglify()
        # Переименование
        .pipe rename {
            suffix: paths.client.js.suffix
        }
        # Сохранение
        .pipe gulp.dest paths.client.js.to
        .on 'error', error
        .on 'finish', next

    return

# Копирование
gulp.task 'client:copy', (next)->
    gulp.src paths.client.copy.from
        # Сохранение
        .pipe gulp.dest paths.client.copy.to
        .on 'error', error
        .on 'finish', next
    
    return

gulp.task 'client:templates', (next)->
    gulp.src paths.client.templates.from
        # Сохранение
        .pipe gulp.dest paths.client.templates.to
        .on 'error', error
        .on 'finish', next
    
    return

###
-------------------------------------
Сервер
-------------------------------------
###
# Coffee
gulp.task 'development:coffee', (next)->
    gulp.src paths.server.coffee.from
        # Рендер Coffee
        .pipe coffee({bare: true}).on 'error', error
        # Сохранение
        .pipe gulp.dest paths.server.coffee.to
        .on 'error', error
        .on 'finish', next

    return

# Cson
gulp.task 'development:cson', (next)->
    gulp.src paths.server.cson.from
        # Рендер Cson
        .pipe cson().on 'error', error
        .pipe gulp.dest paths.server.cson.to
        .on 'error', error
        .on 'finish', next

    return

###
-------------------------------------
General
-------------------------------------
###
# Документация
gulp.task 'general:jsdoc', (next)->
    gulp.src paths.general.jsdoc.from
        # Рендер Cson
        .pipe jsdoc.parser().on 'error', error

        # Сохраниение в формате JSON
        # .pipe gulp.dest paths.general.jsdoc.to
        # Рендер в HTML документ
        .pipe jsdoc.generator paths.general.jsdoc.to
        .on 'error', error
        .on 'finish', next
    
    return

# Удаление сборки
gulp.task 'general:clean', (next)->
    gulp.src paths.general.clean.from, {read: false}
        # Удаление всего
        .pipe clean()
        .on 'error', error
        .on 'finish', next

    return

# Backup
gulp.task 'general:backup', (next)->
    time = new Date().getTime()
    version = getPackageVersion()

    gulp.src paths.general.backup.from, { base: './' }
        .pipe zip "bu-#{version}-#{time}.zip"
        .pipe gulp.dest paths.general.backup.to
        .on 'error', error
        .on 'finish', next

    return

gulp.task 'general:backup:cron', (next)->
    new CronJob getCronTime times.backup, ->
        console.log "#{colors.green '[CRON]'} Start make backup"
        gulp.start 'general:backup'
    , null, true, "America/Los_Angeles"

    next()
    return

# Release
gulp.task 'general:release', (next)->
    time = new Date().getTime()
    version = getPackageVersion()

    gulp.src paths.general.release.from, { base: './' }
        .pipe zip "release-#{version}-#{time}.zip"
        .pipe gulp.dest paths.general.release.to
        .on 'error', error
        .on 'finish', next
    
    return

###
-------------------------------------
Test
-------------------------------------
###
# Mocha
gulp.task 'test:mocha', (next)->
    gulp.src paths.general.test.from, {read: false}
        .pipe mocha {
            reporter: 'nyan'
            timeout: 2
        }
        .on 'error', error
        # .on 'finish', next
        
    next()

###
-------------------------------------
Watch
-------------------------------------
###
# Server
gulp.task 'watch:development:coffee', ->
    gulp.watch paths.server.coffee.from, gulpsync.sync [
        'development:coffee'
    ]
gulp.task 'watch:development:cson', ->
    gulp.watch paths.server.cson.from, gulpsync.sync [
        'development:cson'
    ]

# Client
gulp.task 'watch:client:coffee', ->
    gulp.watch paths.client.coffee.from, gulpsync.sync [
        'client:coffee'
    ]
gulp.task 'watch:client:js', ->
    gulp.watch paths.client.js.from, gulpsync.sync [
        'client:js'
    ]
gulp.task 'watch:client:scss', ->
    gulp.watch paths.client.scss.from, gulpsync.sync [
        'client:scss'
    ]
gulp.task 'watch:client:copy', ->
    gulp.watch paths.client.copy.from , gulpsync.sync [
        'client:copy'
    ]
gulp.task 'watch:client:templates', ->
    gulp.watch paths.client.templates.from , gulpsync.sync [
        'client:templates'
    ]

# General
gulp.task 'watch:test:mocha', ->
    gulp.watch paths.general.test.from, gulpsync.sync [
        'test:mocha'
    ]

gulp.task 'watch:general:jsdoc', ->
    gulp.watch paths.general.jsdoc.from, gulpsync.sync [
        'general:jsdoc'
    ]

# Parent
gulp.task 'development', gulpsync.async [
    'development:coffee'
    'development:cson'
]

gulp.task 'client', gulpsync.async [
    'client:coffee'
    'client:js'
    'client:scss'
    'client:copy'
    'client:templates'
]

gulp.task 'general', gulpsync.async [
    'general:jsdoc'
    'general:clean'
    'general:backup'
    'general:release'
]

gulp.task 'test', gulpsync.async [
    'test:mocha'
]

gulp.task 'watch', gulpsync.async [
    'watch:development:coffee'
    'watch:development:cson'

    'watch:client:coffee'
    'watch:client:js'
    'watch:client:scss'
    'watch:client:copy'
    'watch:client:templates'

    'watch:test:mocha'
    'watch:general:jsdoc'
]

# Init
gulp.task 'build', gulpsync.sync [
    # 'general:backup'
    'general:clean'

    [
        'development'
        'client'
    ]
]

gulp.task 'release', gulpsync.sync [
    'build'
    'general:release'
]

gulp.task 'default', gulpsync.sync [
    'build'
    'general:backup:cron'
    'watch'
]