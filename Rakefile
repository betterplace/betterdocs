# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'betterdocs'
  author      'betterplace Developers'
  email       'developers@betterplace.org'
  homepage    "https://github.com/betterplace/#{name}"
  summary     'Betterplace API documentation library'
  description "This library provides tools to generate API documention for a web site's REST-ful JSON API."
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.rvmrc',
    '.ruby-version', '.AppleDouble', 'tags', '.DS_Store', '.utilsrc',
    '.bundle', 'errors.lst', '.yardoc', '.history'
  readme      'README.md'
  title       "#{name.camelize}"

  licenses    << 'Apache-2.0'

  dependency 'tins',           '~>1.3', '>=1.3.5'
  dependency 'rails',          '>=3', '<9'
  dependency 'term-ansicolor', '~>1.3'
  dependency 'complex_config', '~>0.5'
  dependency 'infobar'
  dependency 'mize'
  development_dependency 'rake'
  development_dependency 'simplecov'
  development_dependency 'rspec'
  development_dependency 'debug'
  development_dependency 'all_images'
end

task :default => :spec
