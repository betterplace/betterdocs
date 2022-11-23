Betterdocs API Documentation
============================

[![Code Climate](https://codeclimate.com/repos/51128561f3ea0022cc027f31/badges/2a9719de54628d821871/gpa.png)](https://codeclimate.com/repos/51128561f3ea0022cc027f31/feed)

DESCRIPTION
-----------

This library can be used to document a Rails-based API.

LICENSE
-------

Apache License Version 2.0, see also the COPYING file.

USAGE EXAMPLES
--------------

These are some examples. Note that they are neither complete, nor work out of the box.

This api generator requires that you follow the [representer pattern](http://nicksda.apotomo.de/2011/12/ruby-on-rest-introducing-the-representer-pattern/) to decorate the objects you want to render. Betterdocs comes with it's own representer support baked in.

## Controller

betterdocs comes with a DSL for the (Rails) controllers - see examples below.

```ruby
class ThingsController < ApplicationController
  # :nocov: Documentation
  doc :action do
    section     :things_list
    title       'A List of things ⇄ [Details](things_details.md)'
    description to <<-end
      This action shows a list of things. **Markdown** can be used.
    end

    param :order do
      description to <<-end
        Optional parameter to order the list.
      end
      required    no
      value       'created_at:ASC'
    end

    response do
      generate_fake_result_with_representer
    end
  end
  # :nocov:
  def index
    render json: real_result_with_representer
  end

  # :nocov: Documentation
  doc :action do
    section     :things_details
    title       'Things Details ⇄ [List](things_list.md)'
    description to <<-end
      The details of a thing. You must give an id for the thing
    end

    param :thing_id do
      description 'The id of the thing you want to see. Required.'
      required    yes # this is the default
      value       38
    end

    response do
      generate_fake_details_response_with_representer
    end
  end
  # :nocov:
  def show
    render json: real_result_with_representer
  end
end
```

## Representer

Betterdocs comes with its own representer class. It is not documented
yet but works kind of like [ROAR](https://github.com/apotonick/roar).

```ruby
module ThingsRepresenter

  extend ActiveSupport::Concern
  include Betterdocs::Representer

  property :microfleem_count, if: -> { has_microfleems? }, as: :number_of_fleems do
    description 'If we have microfleems, return the count'
    types       Integer
    example     '5000'
  end

  property :title, as: :name do
    description to <<-end
      Represent the internal field "title" as the name of the thing
    end
    types       String
    example     'my_name'
  end

  # Add a link to the links list in the resulting JSON.
  link :self do
    description to <<-end
      Link to this resource itself
      (<a href="opinion_details.md">things details</a>)
    end
    url { thing_url(id) }
  end
end
```

GENERATING
----------

`rake doc:api:push` will push the documentation onto a git branch.
`rake doc:api:swagger` will call Swagger.

RELEASING
---------

Edit `Rakefile` and `VERSION` and run `rake` (because we use gemhadar). Commit changes, run `rake gem:push` and `git push --tags`.

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
- Display enums as possible values in representers
- Automatically document error result documents
- Use private flag action/controller to skip docu creation by default. Make it
  configurable to create private API as well.

