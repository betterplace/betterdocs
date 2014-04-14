Betterdocs API Documentation
============================

[![Code Climate](https://codeclimate.com/repos/51128561f3ea0022cc027f31/badges/2a9719de54628d821871/gpa.png)](https://codeclimate.com/repos/51128561f3ea0022cc027f31/feed)

DESCRIPTION
-----------

This library can be used to document a rails based API.

LICENSE
-------

Apache License Version 2.0, see also the COPYING file.


AUTHORS
-------
Florian Frank <flori@ping.de>

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
- Display links of subrepresenters below subrepresenter properties.
