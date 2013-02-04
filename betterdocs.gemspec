# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "betterdocs"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["betterplace Developers"]
  s.date = "2013-02-05"
  s.description = "This library provides tools to generate API documention for a web site's REST-ful JSON API."
  s.email = "developers@betterplace.org"
  s.extra_rdoc_files = ["README.md", "lib/betterdocs.rb", "lib/betterdocs/collector.rb", "lib/betterdocs/dsl.rb", "lib/betterdocs/generator/markdown.rb", "lib/betterdocs/mix_into_controller.rb", "lib/betterdocs/section.rb", "lib/betterdocs/version.rb"]
  s.files = [".gitignore", "Gemfile", "README.md", "Rakefile", "VERSION", "betterdocs.gemspec", "lib/betterdocs.rb", "lib/betterdocs/collector.rb", "lib/betterdocs/dsl.rb", "lib/betterdocs/generator/markdown.rb", "lib/betterdocs/mix_into_controller.rb", "lib/betterdocs/section.rb", "lib/betterdocs/version.rb"]
  s.homepage = "http://github.com/betterplace/betterdocs"
  s.rdoc_options = ["--title", "Betterdocs -- ", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Betterplace API documentation library"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 0.2.0"])
      s.add_development_dependency(%q<utils>, [">= 0"])
      s.add_runtime_dependency(%q<dslkit>, ["~> 0.2"])
      s.add_runtime_dependency(%q<tins>, ["~> 0.7"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 0.2.0"])
      s.add_dependency(%q<utils>, [">= 0"])
      s.add_dependency(%q<dslkit>, ["~> 0.2"])
      s.add_dependency(%q<tins>, ["~> 0.7"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 0.2.0"])
    s.add_dependency(%q<utils>, [">= 0"])
    s.add_dependency(%q<dslkit>, ["~> 0.2"])
    s.add_dependency(%q<tins>, ["~> 0.7"])
  end
end
