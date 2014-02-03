Betterdocs API Documentation
============================

[![Code Climate](https://codeclimate.com/repos/51128561f3ea0022cc027f31/badges/2a9719de54628d821871/gpa.png)](https://codeclimate.com/repos/51128561f3ea0022cc027f31/feed)

DESCRIPTION
-----------

This library can be used to document a rails based API.

*TODO*

LICENSE
-------

Apache License Version 2.0, see also the COPYING file.


AUTHORS
-------


TODO
----

- Implement some kind of scheme for versioning or at least better commit messages;
  we also may want to keep other peoples commits if possible (how?).
- Refactor configuration to avoid singleton antipattern
- Create method in generator that considers a given string to be markdown
  formatted and compiles it to html (as a work around to put multiline
  descriptions inside of html tables in a markdown)
- Display enums as possible values
- Automatically document HTTP result codes of responses
- Automatically document error result documents
- Document order parameters
- Maybe create a file where sections are defined and can be documented as well.
- Check if api\_property with { as: :foobar } options work
- Differentiate between value and example in action parameters. Values shall be
  used for url generation, example as documentation example.

WON'T DO
--------
- Prefix all dsl commands with api\_
