# -*- encoding: utf-8 -*-
# stub: betterdocs 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "betterdocs".freeze
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["betterplace Developers".freeze]
  s.date = "2016-12-07"
  s.description = "This library provides tools to generate API documention for a web site's REST-ful JSON API.".freeze
  s.email = "developers@betterplace.org".freeze
  s.extra_rdoc_files = ["README.md".freeze, "lib/betterdocs.rb".freeze, "lib/betterdocs/controller_collector.rb".freeze, "lib/betterdocs/dsl.rb".freeze, "lib/betterdocs/dsl/common.rb".freeze, "lib/betterdocs/dsl/controller.rb".freeze, "lib/betterdocs/dsl/controller/action.rb".freeze, "lib/betterdocs/dsl/controller/action/param.rb".freeze, "lib/betterdocs/dsl/controller/action/response.rb".freeze, "lib/betterdocs/dsl/controller/controller.rb".freeze, "lib/betterdocs/dsl/controller/controller_base.rb".freeze, "lib/betterdocs/dsl/json_params.rb".freeze, "lib/betterdocs/dsl/json_params/param.rb".freeze, "lib/betterdocs/dsl/json_type_mapper.rb".freeze, "lib/betterdocs/dsl/naming.rb".freeze, "lib/betterdocs/dsl/representer.rb".freeze, "lib/betterdocs/dsl/result.rb".freeze, "lib/betterdocs/dsl/result/collection_property.rb".freeze, "lib/betterdocs/dsl/result/link.rb".freeze, "lib/betterdocs/dsl/result/property.rb".freeze, "lib/betterdocs/generator/config_shortcuts.rb".freeze, "lib/betterdocs/generator/markdown.rb".freeze, "lib/betterdocs/global.rb".freeze, "lib/betterdocs/json_params_representer.rb".freeze, "lib/betterdocs/json_params_representer_collector.rb".freeze, "lib/betterdocs/json_time_with_zone.rb".freeze, "lib/betterdocs/mix_into_controller.rb".freeze, "lib/betterdocs/railtie.rb".freeze, "lib/betterdocs/rake_tasks.rb".freeze, "lib/betterdocs/representer.rb".freeze, "lib/betterdocs/result_representer.rb".freeze, "lib/betterdocs/result_representer_collector.rb".freeze, "lib/betterdocs/section.rb".freeze, "lib/betterdocs/version.rb".freeze]
  s.files = [".codeclimate.yml".freeze, ".gitignore".freeze, ".rspec".freeze, ".travis.yml".freeze, "COPYING".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "betterdocs.gemspec".freeze, "lib/betterdocs.rb".freeze, "lib/betterdocs/controller_collector.rb".freeze, "lib/betterdocs/dsl.rb".freeze, "lib/betterdocs/dsl/common.rb".freeze, "lib/betterdocs/dsl/controller.rb".freeze, "lib/betterdocs/dsl/controller/action.rb".freeze, "lib/betterdocs/dsl/controller/action/param.rb".freeze, "lib/betterdocs/dsl/controller/action/response.rb".freeze, "lib/betterdocs/dsl/controller/controller.rb".freeze, "lib/betterdocs/dsl/controller/controller_base.rb".freeze, "lib/betterdocs/dsl/json_params.rb".freeze, "lib/betterdocs/dsl/json_params/param.rb".freeze, "lib/betterdocs/dsl/json_type_mapper.rb".freeze, "lib/betterdocs/dsl/naming.rb".freeze, "lib/betterdocs/dsl/representer.rb".freeze, "lib/betterdocs/dsl/result.rb".freeze, "lib/betterdocs/dsl/result/collection_property.rb".freeze, "lib/betterdocs/dsl/result/link.rb".freeze, "lib/betterdocs/dsl/result/property.rb".freeze, "lib/betterdocs/generator/config_shortcuts.rb".freeze, "lib/betterdocs/generator/markdown.rb".freeze, "lib/betterdocs/generator/markdown/templates/README.md.erb".freeze, "lib/betterdocs/generator/markdown/templates/section.md.erb".freeze, "lib/betterdocs/global.rb".freeze, "lib/betterdocs/json_params_representer.rb".freeze, "lib/betterdocs/json_params_representer_collector.rb".freeze, "lib/betterdocs/json_time_with_zone.rb".freeze, "lib/betterdocs/mix_into_controller.rb".freeze, "lib/betterdocs/railtie.rb".freeze, "lib/betterdocs/rake_tasks.rb".freeze, "lib/betterdocs/representer.rb".freeze, "lib/betterdocs/result_representer.rb".freeze, "lib/betterdocs/result_representer_collector.rb".freeze, "lib/betterdocs/section.rb".freeze, "lib/betterdocs/tasks/doc.rake".freeze, "lib/betterdocs/version.rb".freeze, "spec/assets/app/controllers/api/foos_controller.rb".freeze, "spec/assets/config/betterdocs.yml".freeze, "spec/controller_dsl_spec.rb".freeze, "spec/generator/markdown_spec.rb".freeze, "spec/global_spec.rb".freeze, "spec/json_params_representer_spec.rb".freeze, "spec/json_type_mapper_spec.rb".freeze, "spec/result_representer_dsl_spec.rb".freeze, "spec/result_representer_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "http://github.com/betterplace/betterdocs".freeze
  s.rdoc_options = ["--title".freeze, "Betterdocs -- ".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Betterplace API documentation library".freeze
  s.test_files = ["spec/assets/app/controllers/api/foos_controller.rb".freeze, "spec/controller_dsl_spec.rb".freeze, "spec/generator/markdown_spec.rb".freeze, "spec/global_spec.rb".freeze, "spec/json_params_representer_spec.rb".freeze, "spec/json_type_mapper_spec.rb".freeze, "spec/result_representer_dsl_spec.rb".freeze, "spec/result_representer_spec.rb".freeze, "spec/spec_helper.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<tins>.freeze, [">= 1.3.5", "~> 1.3"])
      s.add_runtime_dependency(%q<rails>.freeze, ["< 6", ">= 3"])
      s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
      s.add_runtime_dependency(%q<complex_config>.freeze, ["~> 0.5"])
    else
      s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<tins>.freeze, [">= 1.3.5", "~> 1.3"])
      s.add_dependency(%q<rails>.freeze, ["< 6", ">= 3"])
      s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
      s.add_dependency(%q<complex_config>.freeze, ["~> 0.5"])
    end
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<tins>.freeze, [">= 1.3.5", "~> 1.3"])
    s.add_dependency(%q<rails>.freeze, ["< 6", ">= 3"])
    s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
    s.add_dependency(%q<complex_config>.freeze, ["~> 0.5"])
  end
end
