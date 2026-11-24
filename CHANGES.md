# Changes

## 2026-11-24 v0.16.0

### Features
- Added an explicit `json` runtime dependency (`>= 3`, `< 4`)
  to the `Rakefile` and regenerated `betterdocs.gemspec`.

### Improvements
- Updated Ruby to **3.4.13** in `.tool-versions`.
- Updated `gem_hadar` development dependency to **2.27.2**.
- Removed vim modeline comments from `Gemfile` and `Rakefile`.
- Consolidated `require 'spec_helper'` into `.rspec` via
  `-rspec_helper`, removing the redundant line from all 11
   spec files.

### Build & CI
- Added a GitHub Pages workflow (`.github/workflows/static.yml`)
  to deploy YARD docs from `doc/` on push to `master` and via
  `workflow_dispatch`; registered via `github_workflows('static.yml'
  => {})` in `Rakefile`.

### Testing
- Added `json_params_representer_collector_spec.rb` with 9
  examples, bringing `JsonParamsRepresenterCollector` to 100%
  line and branch coverage.

### Documentation
- Added a `LINKS` section to `README.md` with links to the
  source repository and the hosted YARD API reference
  (https://betterplace.github.io/betterdocs/).
- Restructured `CHANGES.md` history into categorized
  `### Breaking` / `Features` / `Fixes` / `Improvements` /

## 2026-01-28 v0.15.1

### Improvements
- Refactored Rails integration by removing the top-level
  `RakeTasks` class and consolidating rake task loading into
  `Betterdocs::Railtie#rake_tasks`.
- Updated `spec_helper.rb` to use `GemHadar::SimpleCov.start` instead of
  manually requiring and configuring `SimpleCov`.

### Build & CI
- Updated Semaphore CI to use the `ubuntu2404` image.
- Modified `.all_images.yml` to use parallel `bundle install` and added
  `Gemfile.lock` cleanup steps for consistent builds.
- Updated the `gemspec` to include `.tool-versions` and exclude
  `lib/betterdocs/rake_tasks.rb` from the file list.
- Updated the development dependency `gem_hadar` to version **2.17.0**.
- Added `.tool-versions` to specify Ruby **3.4.8** for the development
  environment.

## 2026-01-08 v0.15.0

### Features
- Added a `CHANGES.md` changelog file and configured it for inclusion
  in the gem package.

### Build & CI
- Added Ruby **4.0** to the CI test matrix.
- Added `openssl-dev` to the Docker image and updated the test script to
  use `bundle update --all`, `bundle install`, and `bundle exec rake spec`.
- Removed the `.tool-versions` file.

### Testing
- Added a `TODO` message to a skipped test case.

## 2025-02-13 v0.14.0

### Build & CI
- Renamed `COPYING` to `LICENSE` and updated it with the full Apache 2.0
  license text.
- Added `Apache-2.0` to the gemspec licenses metadata.
- Added `all_images` as a development dependency.
- Updated the gemspec files list to include `.all_images.yml` and
  `LICENSE`.

## 2025-02-13 v0.13.1

### Build & CI
- Added `all_images` as a development dependency to the `Rakefile` and
  introduced `.all_images.yml` to define a matrix of Ruby Docker images
  (**3.1** through **3.4**) for automated testing.
- Updated the local development environment to use Ruby **3.4.1** by
  modifying `.tool-versions`.

### Testing
- Fixed the URL extraction regex in `spec/controller_dsl_spec.rb` to
  correctly isolate the specification path and prevent the generation of
  the `betterdocs/` prefix in expected output.

## 2025-01-07 v0.13.0

### Build & CI
- Relaxed the `rails` version constraint in the gemspec to
  support versions **8.0** through **8.9** (now `>= 3`, `< 9`).
- Updated the `rails` dependency in the `Rakefile` to match the
  new version range.

## 2024-09-17 v0.12.5

### Improvements
- Replaced `byebug` with the `debug` gem for development debugging.
- Updated the Ruby version to **3.2.5** and removed the pinned
  `bundler` version from `.tool-versions`.
- Updated `gem_hadar` development dependency constraint to `~> 1.17.1`.
- Simplified `betterdocs.gemspec` syntax by using `add_development_dependency`
  and `add_runtime_dependency` methods directly.
- Removed `.byebug_history` from `.gitignore` and `Rakefile` ignore lists.
- Added `ostruct` requirement to `spec/spec_helper.rb`.

### Fixes
- Ensure generated response examples only include data from the response
  payload by using `action.response.data.as_json`.

## 2023-04-06 v0.12.4

### Fixes
- Force response data to JSON in the Swagger generator by
  invoking `to_json` on `action.response` before parsing.

## 2023-04-04 v0.12.3

### Fixes
- Allow endpoint paths to include hyphens in their URLs, such as in
  `.../api_v4/clients/ww-testclient/projects.json`, by updating the
  regular expression in `lib/betterdocs/generator/swagger.rb`.

## 2022-12-10 v0.12.2

### Improvements
- Removed the `implement :to_hash, :submodule`
  directive from `Betterdocs::Responding` to prevent unintended
  behavior.

## 2022-12-09 v0.12.1

### Improvements
- Moved the `Betterdocs::Responding` module include from the
  `Betterdocs::Representer` module to the
  `Betterdocs::ResultRepresenter` module to refine the inheritance
  hierarchy.

## 2022-12-09 v0.12.0

### Features
- Introduce the `Betterdocs::Responding` module to define the interface
  for objects used in API responses.
- Require response data to include `Betterdocs::Responding` and implement
  the `#to_hash` method.

### Improvements
- Enhance error messages in `Betterdocs::Dsl::Controller::Action::Response`
  to distinguish between missing data and invalid data types.
- Add validation in `#to_json` to raise an error if the response data is
  `nil` or does not include `Betterdocs::Responding`.
- Include `Betterdocs::Responding` in `Betterdocs::Representer` and alias
  `#as_json` to `#to_hash`.

### Testing
- Update `response_spec.rb` to verify that response data includes
  `Betterdocs::Responding` and handles invalid data types.
- Remove a skipped test from `json_params_representer_spec.rb`.

## 2022-12-07 v0.11.0

### Features
- Raise an `Error` if the `data` key is missing or empty in
  the example response.

### Improvements
- Propagate the original `Error` object in the `data` method
  of `Response` instead of wrapping it.
- Upgrade the Ruby runtime requirement to **3.1.3**.

### Testing
- Update response specs to use `to_hash` and verify the new
  empty data validation.

### Documentation
- Add a section describing the `rake` tasks for generating and
  pushing API documentation.
- Clarify the purpose of the controller DSL in the README.

## 2022-08-16 v0.10.0

### Improvements
- Update `ERB` instantiation in `markdown.rb` to use the
  `trim_mode` keyword argument for compatibility with Ruby **3.1**.

## 2022-07-20 v0.9.2

### Build & CI
- Updated the `rails` dependency constraint to allow
  versions up to **< 8**.
- Updated the `Rakefile` `homepage` to use `https`.
- Regenerated `betterdocs.gemspec` with the updated
  `rails` dependency and `homepage`.

### Documentation
- Added `RELEASING` section to `README.md`.
- Updated `README.md` release instructions to include
  editing `VERSION` and running `rake gem:push`.

## 2022-07-14 v0.9.1

### Fixes
- Fixed a bug in the `sections` method of
  `lib/betterdocs/generator/config_shortcuts.rb` by
  iterating directly over `config.api_controllers`
  instead of using `Dir` globbing, resolving an
  issue where controller paths were not processed
  correctly.

### Improvements
- Upgraded the Ruby version to **3.0.4** and the
  Bundler version to **2.3.8** in the
  `.tool-versions` file.

### Build & CI
- Updated the CI environment to use `ubuntu2004`
  in the Semaphore configuration, replacing
  `ubuntu1804`.
- Updated the `gem_hadar` dependency to version
  **1.12.0** in the gemspec.

### Documentation
- Wrapped Ruby code examples in the README with
  `ruby` language fences to enable proper syntax
  highlighting.

## 2021-09-21 v0.9.0

### Improvements
- Updated the development Ruby version to **3.0.2** in `.tool-versions`.

## 2021-07-30 v0.8.1

### Features
- Add an OpenAPI 3.0.2 Swagger JSON generator that creates
  interactive API documentation from existing DSL definitions.
- Introduce `swagger_output_directory`, `swagger_assets`, and
  related configuration options to `Betterdocs::Global`.
- Support an optional descriptor for properties in the Swagger
  output, allowing non-required fields to be documented.
- Add a `doc:api:swagger` rake task to generate the Swagger
  documentation bundle.

### Fixes
- Ensure compatibility with Ruby **3.0** by explicitly requiring
  `active_support/time_with_zone` and correcting keyword argument
  splat usage in `Betterdocs::Dsl::JsonParams::Param` and
  `Betterdocs::Dsl::Result::Property`.
- Update `Betterdocs::Representer#doc` and
  `Betterdocs::ResultRepresenter#doc` to pass keyword arguments
  correctly to `docs.add_element`.

### Improvements
- Remove the `.travis.yml` configuration file in favor of existing
  CI setups.
- Refactor `Betterdocs::Global` URL handling and asset iteration
  for clarity and consistency.

### Build & CI
- Add Ruby version management via `.tool-versions`.
- Update gemspec metadata and file listings to include new
  Swagger generator files and static assets.

## 2021-06-01 v0.7.1

### Fixes
- Raise `TypeError` in `derive_json_type_from` for unmapped types to prevent
  invalid Swagger specs.

## 2021-05-21 v0.7.0

### Features
- Added support for Ruby 3.0.1.

### Fixes
- Replaced `ActiveSupport::TimeWithZone` checks with `respond_to?(:iso8601)` in
  `json_params/param.rb` and `result/property.rb` for compatibility.
- Updated `doc` method calls in `representer.rb` and `result_representer.rb`
  to explicitly pass keyword arguments.

### Build & CI
- Migrated CI configuration from Travis CI to Semaphore.
- Updated `.gemspec` dependencies and removed outdated Ruby version
  specifications.

## 2019-08-23 v0.6.7

### Fixes
- Remove debug `puts` statements from the markdown template for
  section rendering.

### Improvements
- Expand the `rails` dependency constraint to support Rails **6**,
  changing the upper bound from `<6` to `<7`.
- Update the CI Ruby version from **2.5.0** to **2.6.3** in
  `.travis.yml`.

### Documentation
- Correct capitalization and whitespace in the `README.md`
  description and code examples.

## 2018-11-23 v0.6.5

### Improvements
- Allowed custom strings for the `required` field in the Markdown generator
  template, replacing the previous hardcoded boolean labels.

## 2018-10-10 v0.6.4

### Fixes
- Raised a custom `Error` in `Betterdocs::Dsl::Controller::Action::Response#data`
  to filter backtraces to the Rails root, improving error visibility.
- Updated `Betterdocs::Generator::Markdown#fail_while_rendering` to omit the
  template name for response errors and label the backtrace as "Location:".

### Improvements
- Changed the code block language in `section.md.erb` from "Rebol" to
  "Cirru" for improved syntax highlighting.

### Build & CI
- Added `rake` as a development dependency in `Rakefile` and
  `betterdocs.gemspec`.
- Updated Travis CI configuration to test on Ruby **2.4.3** and **2.5.0**,
  including a `before_install` step to update RubyGems and Bundler.

## 2017-08-18 v0.6.3

### Fixes
- Fixed the display of nested attributes in the generated documentation.

## 2017-03-30 v0.6.2

### Fixes
- Removed an extra blank line from the generated Markdown table in
  `section.md.erb` to prevent rendering issues with GitHub's parser.

## 2017-03-30 v0.6.1

### Features
- Allow using markdown in link `full_name` fields.

## 2017-03-30 v0.6.0

### Features
- Support Markdown syntax in section descriptions within
  HTML tables.
- Add automatic HTML sanitization to string values in result
  properties via a new `Betterdocs::Sanitizer` class.

### Fixes
- Fix syntax error in `README.md.erb` template to correctly
  render section links.
- Ensure asset file paths are resolved relative to the Rails
  root during document generation.

### Improvements
- Refactor internal structure of `Response` and `Global`
  modules for improved clarity.
- Update infobar progress messages to include spacing and
  completion details.
- Remove development environment restriction from global
  configuration loading.

### Build & CI
- Add `mize` as a runtime dependency for HTML sanitization.

### Testing
- Refactor spec structure and add new unit tests for
  `Sanitizer`, `Property`, `Link`, `CollectionProperty`,
  `Param`, `Response`, and `Markdown` generator.

## 2017-03-20 v0.5.0

### Features
- Add automatic HTML sanitization to string values in result
  properties via the `Betterdocs::Sanitizer` class.
- Add support for a global `default_sanitize` configuration option
  in `Betterdocs::Global`.

### Fixes
- Resolve asset paths relative to the Rails root directory to
  ensure correct file copying during documentation generation.
- Replace deprecated `Fixnum` references with `Integer` in specs
  for Ruby **2.4.0** compatibility.
- Load `byebug` only on the MRI platform to support other Ruby
  implementations.

### Improvements
- Implement progress bars using the `infobar` gem to display
  generation status and estimated time of completion.
- Refactor the representer lookup logic in
  `Betterdocs::Dsl::Controller::Action::Response` for clarity and
  robustness.
- Enable YAML-based configuration in all environments, removing
  the previous restriction to development mode.

### Build & CI
- Add `mize` as a runtime dependency to support the new sanitizer
  functionality.
- Add `infobar` as a runtime dependency to support progress
  reporting.
- Re-add `.travis.yml` to configure CI with Ruby **2.4.0**.
- Remove CodeClimate test reporter configuration and dependencies.

### Testing
- Refactor and expand the spec suite structure to cover smaller
  units, including `Param`, `Response`, `Property`, `Link`, and
  `Sanitizer`.
- Add test fixtures for assets and global configuration in spec
  assets.

## 2016-12-07 v0.4.0

### Improvements
- Use `quirks_mode` when generating JSON response examples in
  markdown templates to ensure compatibility with modern Rails
  versions.
- Replace `ActionController::Parameters` with `HashWithIndifferentAccess`
  in `JsonParamsRepresenter` to avoid relying on Rails-specific
  parameter classes.

### Fixes
- Allow compatibility with Rails 5 by removing the version constraint
  that previously restricted `rails` to versions below 5.

## 2016-06-13 v0.3.0

### Features
- Integrate `complex_config` to support YAML-based configuration for `Betterdocs::Global`
- Add a Rails railtie to automatically initialize the global configuration
- Serialize `ActiveSupport::TimeWithZone` values as ISO 8601 strings in JSON output
- Introduce `api_url`, `asset_url`, and `platform_url` methods to manage and parse host settings
- Add a `controllers_dir` accessor to customize the directory for API controller discovery

### Fixes
- Improve error handling for URL generation failures by raising a descriptive exception

### Improvements
- Refactor the assets configuration API to support both hash and individual assignment

### Build & CI
- Drop support for Ruby **2.0**, **2.1**, and **2.2** in the CI test matrix
- Update the CI test matrix to run against Ruby **2.3.1**
- Ensure `Bundler` is updated before installation in the CI environment

### Testing
- Add a test suite for `Betterdocs::Global` to verify configuration and URL handling
- Update API controller tests to be independent of the absolute file path

## 2016-03-30 v0.2.0

### Breaking
- Removed the inclusion of `Tins::To` from `Betterdocs::Dsl::Common`.

### Improvements
- Upgraded the development dependency on `gem_hadar` to **1.6.1**.
- Added a `.codeclimate.yml` file to configure Code Climate.

### Build & CI
- Removed the `.ruby-version` file.

## 2015-09-04 v0.1.0

  * Start
