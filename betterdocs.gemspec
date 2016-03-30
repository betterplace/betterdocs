# -*- encoding: utf-8 -*-
# stub: betterdocs 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "betterdocs"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["betterplace Developers"]
  s.date = "2016-03-30"
  s.description = "This library provides tools to generate API documention for a web site's REST-ful JSON API."
  s.email = "developers@betterplace.org"
  s.extra_rdoc_files = ["README.md", "lib/betterdocs.rb", "lib/betterdocs/controller_collector.rb", "lib/betterdocs/dsl.rb", "lib/betterdocs/dsl/common.rb", "lib/betterdocs/dsl/controller.rb", "lib/betterdocs/dsl/controller/action.rb", "lib/betterdocs/dsl/controller/action/param.rb", "lib/betterdocs/dsl/controller/action/response.rb", "lib/betterdocs/dsl/controller/controller.rb", "lib/betterdocs/dsl/controller/controller_base.rb", "lib/betterdocs/dsl/json_params.rb", "lib/betterdocs/dsl/json_params/param.rb", "lib/betterdocs/dsl/json_type_mapper.rb", "lib/betterdocs/dsl/naming.rb", "lib/betterdocs/dsl/representer.rb", "lib/betterdocs/dsl/result.rb", "lib/betterdocs/dsl/result/collection_property.rb", "lib/betterdocs/dsl/result/link.rb", "lib/betterdocs/dsl/result/property.rb", "lib/betterdocs/generator/config_shortcuts.rb", "lib/betterdocs/generator/markdown.rb", "lib/betterdocs/global.rb", "lib/betterdocs/json_params_representer.rb", "lib/betterdocs/json_params_representer_collector.rb", "lib/betterdocs/mix_into_controller.rb", "lib/betterdocs/rake_tasks.rb", "lib/betterdocs/representer.rb", "lib/betterdocs/result_representer.rb", "lib/betterdocs/result_representer_collector.rb", "lib/betterdocs/section.rb", "lib/betterdocs/version.rb"]
  s.files = [".codeclimate.yml", ".gitignore", ".rspec", ".travis.yml", "COPYING", "Gemfile", "LICENSE", "README.md", "Rakefile", "VERSION", "betterdocs.gemspec", "lib/betterdocs.rb", "lib/betterdocs/controller_collector.rb", "lib/betterdocs/dsl.rb", "lib/betterdocs/dsl/common.rb", "lib/betterdocs/dsl/controller.rb", "lib/betterdocs/dsl/controller/action.rb", "lib/betterdocs/dsl/controller/action/param.rb", "lib/betterdocs/dsl/controller/action/response.rb", "lib/betterdocs/dsl/controller/controller.rb", "lib/betterdocs/dsl/controller/controller_base.rb", "lib/betterdocs/dsl/json_params.rb", "lib/betterdocs/dsl/json_params/param.rb", "lib/betterdocs/dsl/json_type_mapper.rb", "lib/betterdocs/dsl/naming.rb", "lib/betterdocs/dsl/representer.rb", "lib/betterdocs/dsl/result.rb", "lib/betterdocs/dsl/result/collection_property.rb", "lib/betterdocs/dsl/result/link.rb", "lib/betterdocs/dsl/result/property.rb", "lib/betterdocs/generator/config_shortcuts.rb", "lib/betterdocs/generator/markdown.rb", "lib/betterdocs/generator/markdown/templates/README.md.erb", "lib/betterdocs/generator/markdown/templates/section.md.erb", "lib/betterdocs/global.rb", "lib/betterdocs/json_params_representer.rb", "lib/betterdocs/json_params_representer_collector.rb", "lib/betterdocs/mix_into_controller.rb", "lib/betterdocs/rake_tasks.rb", "lib/betterdocs/representer.rb", "lib/betterdocs/result_representer.rb", "lib/betterdocs/result_representer_collector.rb", "lib/betterdocs/section.rb", "lib/betterdocs/tasks/doc.rake", "lib/betterdocs/version.rb", "spec/controller_dsl_spec.rb", "spec/generator/markdown_spec.rb", "spec/json_params_representer_spec.rb", "spec/json_type_mapper_spec.rb", "spec/result_representer_dsl_spec.rb", "spec/result_representer_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/betterplace/betterdocs"
  s.rdoc_options = ["--title", "Betterdocs -- ", "--main", "README.md"]
  s.rubygems_version = "2.5.1"
  s.summary = "Betterplace API documentation library"
  s.test_files = ["spec/controller_dsl_spec.rb", "spec/generator/markdown_spec.rb", "spec/json_params_representer_spec.rb", "spec/json_type_mapper_spec.rb", "spec/result_representer_dsl_spec.rb", "spec/result_representer_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 1.6.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<tins>, [">= 1.3.5", "~> 1.3"])
      s.add_runtime_dependency(%q<rails>, ["< 5", ">= 3"])
      s.add_runtime_dependency(%q<term-ansicolor>, ["~> 1.3"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 1.6.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<tins>, [">= 1.3.5", "~> 1.3"])
      s.add_dependency(%q<rails>, ["< 5", ">= 3"])
      s.add_dependency(%q<term-ansicolor>, ["~> 1.3"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 1.6.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<tins>, [">= 1.3.5", "~> 1.3"])
    s.add_dependency(%q<rails>, ["< 5", ">= 3"])
    s.add_dependency(%q<term-ansicolor>, ["~> 1.3"])
  end
end
