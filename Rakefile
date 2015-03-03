# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'betterdocs'
  author      'betterplace Developers'
  email       'developers@betterplace.org'
  homepage    "http://github.com/betterplace/#{name}"
  summary     'Betterplace API documentation library'
  description "This library provides tools to generate API documention for a web site's REST-ful JSON API."
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.rvmrc',
    '.ruby-version', '.AppleDouble', 'tags', '.DS_Store', '.utilsrc', '.bundle'
  readme      'README.md'
  title       "#{name.camelize} -- "

  dependency 'tins',           '~>1.3', '>=1.3.5'
  dependency 'rails',          '>=3', '<5'
  dependency 'term-ansicolor', '~>1.3'
  development_dependency 'utils'
  development_dependency 'simplecov'
  development_dependency 'rspec'
  development_dependency 'fuubar'
  development_dependency 'autotest'
  development_dependency 'autotest-fsevent'
  development_dependency 'rspec-nc'
end

task :default => :spec
