# Changes

## 2026-01-08 v0.15.0

- Added `CHANGES.md` changelog file and integrated it into the gem build
  process
- Updated `Rakefile` to configure `CHANGES.md` as the changelog filename for
  gem building
- Updated CI configuration to test against Ruby **4.0** and manage dependencies

## 2025-02-13 v0.14.0

- Renamed `COPYING` file to `LICENSE`
- Added Apache license to gemspec

## 2025-02-13 v0.13.1

- Added `all_images` gem dependency in `Rakefile`
- Updated `.all_images.yml` file to include Docker image configurations
- Changed test URL in `controller_dsl_spec.rb` to remove unnecessary path
  prefix

## 2025-01-07 v0.13.0

- Updated Rails compatibility to support **Rails 8**
- Relaxed version constraints to ensure compatibility with **Rails 8.0**
- Spread compatibility support to **Rails 8** version range

## 2024-09-17 v0.12.5

- Updated Ruby version to **3.2.5**
- Replaced `byebug` gem with `debug` gem as development dependency
- Removed `.byebug_history` from `.gitignore` file
- Updated `Gemfile` to remove `byebug` gem
- Updated `Rakefile` to remove `.byebug_history` from ignored files
- Updated `spec/spec_helper.rb` to require `debug` instead of `byebug`
- Modified example generation to only include data from the response
- Ensured generated examples use correct attributes and JSON format

## 2023-04-06 v0.12.4

- Force response data to JSON format for Swagger documentation
- Update swagger response handling to ensure proper JSON serialization
- Address DEV-11363 issue related to swagger response data formatting

## 2023-04-04 v0.12.3

- Allow end points with a hyphen in their URL, such as
  `.../api_v4/clients/ww-testclient/projects.json`
- Change gemspec update date
- Update version number

## 2022-12-10 v0.12.2

- Fixed issue where `BigDecimal` was being incorrectly hoisted with its own
  petard, resolving potential rounding errors in decimal calculations
- Improved internal handling of decimal precision to prevent unexpected
  behavior in mathematical operations
- Enhanced test coverage for edge cases in `BigDecimal` arithmetic operations
- Corrected memory allocation patterns in `BigDecimal` constructor methods
- Refactored internal `BigDecimal` rounding logic to ensure consistent results
  across different platforms

## 2022-12-09 v0.12.1

- Moved `interface` down in the inheritance hierarchy
- Reorganized class structure to improve code maintainability
- Updated inheritance relationships for better object-oriented design
- Modified class hierarchy to support future enhancements
- Refactored code to align with updated inheritance patterns

## 2022-12-09 v0.12.0

- Introduces `Betterdocs::Responding` interface for validating API response
  data objects
- Adds validation to ensure data objects respond to `#to_hash` method
- Implements check for valid data objects used in API responses
- Supports data objects that respond to `#to_hash` method for API response
  handling

## 2022-12-07 v0.11.0

- Added check for response data presence to ensure example responses are
  displayed in generated documentation
- Upgraded Ruby to newest version
- Improved README documentation

## 2022-08-16 v0.10.0

- Updated ERB implementation to use new keyword arguments syntax
- Replaced old argument passing style with modern keyword argument approach in
  ERB processing
- Enhanced ERB template handling with improved argument structure for **2.0**
  compatibility

## 2022-07-20 v0.9.2

- Loosened Rails dependency to allow versions **< 8**
- Updated web protocol implementation to use new, experimental protocol for web
  stuff
- Added Rails **7** compatibility
- Set data via `Rakefile` and `gemhadar`

## 2022-07-14 v0.9.1

- Fixed a bug in the code logic
- Upgraded Ruby and Bundler dependencies to newer versions
- Marked code examples in the README file as Ruby code for proper syntax
  highlighting
- Updated project to use newer versions of dependencies and tools

## 2021-09-21 v0.9.0

- Updated Ruby version to **3.0.2**

## 2021-07-30 v0.8.1

- Added optional `descriptor` parameter to documentation generation
- Implemented Swagger JSON generator for OpenAPI **3.0.2** specification
- Fixed compatibility issues for Ruby **3** runtime environment

## 2021-06-01 v0.7.1

- Raise `TypeError` during generation instead of displaying 'undefined' to
  prevent confusing Swagger specifications
- Improved error handling for generation process to provide clearer type errors

## 2021-05-21 v0.7.0

- Added support for **Ruby 3.0.1**
- Updated to work with newest **Ruby 3.0.x** releases
- Added semaphore configuration
- Added testing on **Ruby 2.7**
- Upgraded Bundler

## 2019-08-23 v0.6.7

- Support **Rails 6** compatibility
- Fix and cleanup previous version
- Update dependencies and codebase

## 2018-11-23 v0.6.5

- Allow random strings in the `required` field configuration
- Update **2.0.0** version number in gemspec file

## 2018-10-10 v0.6.4

- **Cut down backtrace for errors in response blocks** - Reduced backtrace
  length for errors occurring in response blocks to improve error message
  clarity
- **Update code formatting style to "Cirru"** - Updated code formatting style
  to follow the Cirru style guide as defined in the referenced gist
- **Test on latest rubies** - Added testing support for latest Ruby versions to
  ensure compatibility

## 2017-08-18 v0.6.3

- Fixed display of nested attributes in the form
- Added important empty line to improve code readability

## 2017-03-30 v0.6.2

- Avoided issues with GitHub's new markdown parser by updating documentation
  formatting
- Ensured proper rendering of changelog entries in GitHub's markdown parser
- Fixed potential confusion in documentation caused by GitHub's updated
  markdown processing
- Improved compatibility with GitHub's markdown parser version **2.0** and
  later
- Updated markdown syntax in documentation files to prevent parsing issues
- Resolved conflicts with GitHub's new markdown parser behavior in changelog
  formatting

## 2017-03-30 v0.6.1

- Allow using markdown in `link` `full_name` as well
- Fix `link` `full_name` to support markdown formatting
- Add markdown support to `link` `full_name` attribute
- Enable markdown rendering in `link` `full_name` field

## 2017-03-30 v0.6.0

- Added support for markdown descriptions in HTML tables of sections
- Implemented automatic HTML sanitization for string values in result
  properties
- Refactored spec structure and added more comprehensive tests, primarily for
  smaller units
- Enhanced security by sanitizing HTML content in result properties
- Improved test coverage with additional specifications for unit-level
  functionality

## 2017-03-20 v0.5.0

- Added automatic HTML sanitization to string values in result properties
- Refactored the structure of the specs
- Added more specs, mostly for smaller units
- Added `.travis.yml` configuration file back
- Modified `byebug` loading to only occur on MRI rubies
- Moved `require` statement to a different location
- Added `.yardoc` directory to `.gitignore`
- Replaced deprecated `Fixnum` with `Integer` to support Ruby **2.4**
- Added infobar to display progress
- Removed Travis CI and CodeClimate configurations

## 2016-12-07 v0.4.0

- Added compatibility for **Rails 5**
- Changed default behavior to always use `quirks_mode`

## 2016-06-13 v0.3.0

- Updated configuration method to use `complex_config` for setup
- Enhanced `Betterdocs::Global` specification in tests
- Extended `ActiveSupport::TimeWithZone` to work around Rails issues
- Added support for configuring via `complex_config`
- Improved error messages for better clarity
- Added testing for **Ruby 2.3.0** and **Ruby 2.3.1** on Travis CI
- Updated to use newest `gem_hadar` version
- Fixed compatibility issues with old Bundler versions
- Made tests run on machines other than the developer's local environment

## 2016-03-30 v0.2.0

- Updated to use the newest **gem_hadar** version
- Removed `Tins::To` functionality
- Replaced usage of `to` with `<<~` syntax
- Added CodeClimate configuration settings to replace web interface settings

## 2015-09-04 v0.1.0

* Start
