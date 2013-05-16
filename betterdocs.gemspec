# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "betterdocs"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["betterplace Developers"]
  s.date = "2013-05-16"
  s.description = "This library provides tools to generate API documention for a web site's REST-ful JSON API."
  s.email = "developers@betterplace.org"
  s.extra_rdoc_files = ["README.md", "lib/betterdocs.rb", "lib/betterdocs/controller_collector.rb", "lib/betterdocs/dsl.rb", "lib/betterdocs/generator/config_shortcuts.rb", "lib/betterdocs/generator/markdown.rb", "lib/betterdocs/global.rb", "lib/betterdocs/json_type_mapper.rb", "lib/betterdocs/mix_into_controller.rb", "lib/betterdocs/mix_into_representer.rb", "lib/betterdocs/rake_tasks.rb", "lib/betterdocs/representer_collector.rb", "lib/betterdocs/section.rb", "lib/betterdocs/version.rb"]
  s.files = [".gitignore", ".rspec", "COPYING", "Gemfile", "README.md", "Rakefile", "VERSION", "betterdocs.gemspec", "lib/betterdocs.rb", "lib/betterdocs/controller_collector.rb", "lib/betterdocs/dsl.rb", "lib/betterdocs/generator/config_shortcuts.rb", "lib/betterdocs/generator/markdown.rb", "lib/betterdocs/generator/markdown/templates/README.md.erb", "lib/betterdocs/generator/markdown/templates/section.md.erb", "lib/betterdocs/global.rb", "lib/betterdocs/json_type_mapper.rb", "lib/betterdocs/mix_into_controller.rb", "lib/betterdocs/mix_into_representer.rb", "lib/betterdocs/rake_tasks.rb", "lib/betterdocs/representer_collector.rb", "lib/betterdocs/section.rb", "lib/betterdocs/tasks/doc.rake", "lib/betterdocs/version.rb", "spec/controller_dsl_spec.rb", "spec/generator/markdown_spec.rb", "spec/json_type_mapper_spec.rb", "spec/representer_dsl_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/betterplace/betterdocs"
  s.rdoc_options = ["--title", "Betterdocs -- ", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Betterplace API documentation library"
  s.test_files = ["spec/controller_dsl_spec.rb", "spec/generator/markdown_spec.rb", "spec/json_type_mapper_spec.rb", "spec/representer_dsl_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 0.2.1"])
      s.add_development_dependency(%q<utils>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<fuubar>, [">= 0"])
      s.add_development_dependency(%q<autotest>, [">= 0"])
      s.add_development_dependency(%q<autotest-fsevent>, [">= 0"])
      s.add_development_dependency(%q<rspec-nc>, [">= 0"])
      s.add_runtime_dependency(%q<dslkit>, ["~> 0.2"])
      s.add_runtime_dependency(%q<tins>, ["~> 0.7"])
      s.add_runtime_dependency(%q<rails>, ["~> 3.0"])
      s.add_runtime_dependency(%q<roar>, ["~> 0.11.0"])
      s.add_runtime_dependency(%q<term-ansicolor>, ["~> 1.2"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 0.2.1"])
      s.add_dependency(%q<utils>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<fuubar>, [">= 0"])
      s.add_dependency(%q<autotest>, [">= 0"])
      s.add_dependency(%q<autotest-fsevent>, [">= 0"])
      s.add_dependency(%q<rspec-nc>, [">= 0"])
      s.add_dependency(%q<dslkit>, ["~> 0.2"])
      s.add_dependency(%q<tins>, ["~> 0.7"])
      s.add_dependency(%q<rails>, ["~> 3.0"])
      s.add_dependency(%q<roar>, ["~> 0.11.0"])
      s.add_dependency(%q<term-ansicolor>, ["~> 1.2"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 0.2.1"])
    s.add_dependency(%q<utils>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<fuubar>, [">= 0"])
    s.add_dependency(%q<autotest>, [">= 0"])
    s.add_dependency(%q<autotest-fsevent>, [">= 0"])
    s.add_dependency(%q<rspec-nc>, [">= 0"])
    s.add_dependency(%q<dslkit>, ["~> 0.2"])
    s.add_dependency(%q<tins>, ["~> 0.7"])
    s.add_dependency(%q<rails>, ["~> 3.0"])
    s.add_dependency(%q<roar>, ["~> 0.11.0"])
    s.add_dependency(%q<term-ansicolor>, ["~> 1.2"])
  end
end
