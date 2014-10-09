assets = require 'metalsmith-assets'
collections = require 'metalsmith-collections'
feed = require 'metalsmith-feed'
jekyllDates = require 'metalsmith-jekyll-dates'
markdown = require 'metalsmith-markdown'
metallic = require 'metalsmith-metallic'
metalsmith = require 'metalsmith'
more = require 'metalsmith-more'
paginate = require 'metalsmith-collections-paginate'
permalinks = require 'metalsmith-permalinks'
teacup = require 'metalsmith-teacup'

dateThenTitle = (a, b) ->
  if a.date == b.date
    if a.title > b.title then 1 else -1
  else
    if a.date < b.date then 1 else -1

module.exports = (done) ->
  metalsmith __dirname
  .source 'src/documents'
  .metadata
    site:
      title: 'Bites from Good Eggs'
      author: 'Good Eggs'
      url: 'http://bites.goodeggs.com/'
      googleAnalytics:
        id: 'UA-26193287-5'

  .use jekyllDates()
  .use metallic()
  .use markdown()
  .use more()

  .use (files, metalsmith, done) ->
    # Snapshot contents before rendering
    for name, file of files
      file.contentsWithoutLayout = file.contents
    done()

  .use collections
    posts:
      pattern: 'posts/*'
      sortBy: 'date'
      reverse: true
    openSource:
      pattern: 'open_source/*'
      sortBy: dateThenTitle
    authors:
      pattern: 'authors/*'
    news:
      sortBy: 'date'
      reverse: true

  .use paginate
    posts:
      perPage: 10
      first: 'index.html'
      path: 'posts/:num/index.html'
      template: 'posts'

  .use permalinks
    relative: false
    pattern: ':slug'

  # Absolute paths, trailing slashes
  .use (files, metalsmith, done) ->
    for filename, file of files
      file.path = '/' + file.path
      if file.path.length > 1
        file.path += '/'
    done()

  .use feed collection: 'posts'

  # Map layouts to templates
  # .use (files, metalsmith, done) ->
  #   for filename, file of files
  #     continue unless file.layout
  #     file.template = file.layout
  #   done()
  .use teacup directory: 'src/layouts'

  # .use assets
  #   source: 'static'
  #   destination: '.'

  .destination 'build'
  .clean false # handled by gulp
  .build done
