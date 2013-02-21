# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'betterdocs'
  author      'betterplace Developers'
  email       'developers@betterplace.org'
  homepage    "http://github.com/betterplace/#{name}"
  summary     'Betterplace API documentation library'
  description "This library provides tools to generate API documention for a web site's REST-ful JSON API."
  test_dir    'tests'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.rvmrc', '.AppleDouble'
  readme      'README.md'
  title       "#{name.camelize} -- "

  dependency             'dslkit', '~>0.2'
  dependency             'tins',   '~>0.7.1'
  development_dependency 'utils'
end
