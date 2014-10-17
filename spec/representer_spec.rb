require 'spec_helper'

RSpec.describe Betterdocs::Representer do
  module MySubRepresenter
    include Betterdocs::Representer

    property :some_property

    link 'url3' do
      url { 'some_url' }
    end
  end

  module MyRepresenter
    include Betterdocs::Representer

    property :simple

    property :derived

    property :complex do
      represent_with MySubRepresenter
    end

    property :simple_old_name, as: :simple_new_name

    property :derived_old_name, as: :derived_new_name

    property :complex_old_name, as: :complex_new_name do
      represent_with MySubRepresenter
    end

    collection :thingies do
      represent_with MySubRepresenter
    end

    collection :other_thingies, as: :thingies_new_name do
      represent_with MySubRepresenter
    end

    property :if_no, if: -> { no }

    property :unless_yes, unless: -> { yes }

    property :if_predicate, if: -> { simple != 'simple property' }

    property :unless_predicate, unless: -> { simple == 'simple property' }

    link 'url1' do
      url { 'an_url' }
    end

    link 'url2' do
      url { 'another_url' }
    end

    link 'template' do
      url { 'an_url_with{placeholder}' }
      templated true
    end

    def derived
      'derived property'
    end

    def derived_old_name
      'derived old property'
    end
  end

  let :object do
    OpenStruct.new.tap do |o|
      o.simple  = 'simple property'
      o.complex = OpenStruct.new
      o.complex.some_property = 'some property'
      o.simple_old_name = 'simple old property'
      o.complex_old_name = OpenStruct.new
      o.complex_old_name.some_property = 'some old property'
      o.thingies = [
        OpenStruct.new.tap { |t| t.some_property = 'first' },
        OpenStruct.new.tap { |t| t.some_property = 'second' },
      ]
      o.other_thingies = [
        OpenStruct.new.tap { |t| t.some_property = 'first other' },
      ]
      o.if_no = :no
      o.unless_yes = :yes
      o.if_predicate = true
      o.unless_predicate = true
    end
  end

  let :object_as_json do
    MyRepresenter.apply(object).to_json
  end

  let :represented_object do
    JSON(object_as_json)
  end

  it 'can output pretty json' do
    expect(JSON.pretty_generate(MyRepresenter.apply(object))).to include "\n"
  end

  it 'can output ugly json' do
    expect(JSON.generate(MyRepresenter.apply(object))).to_not include "\n"
  end

  it 'supports simple properties' do
    expect(represented_object['simple']).to eq 'simple property'
  end

  it 'supports derived properties' do
    expect(represented_object['derived']).to eq 'derived property'
  end

  it 'supports complex properties' do
    expect(represented_object['complex']['some_property']).to eq 'some property'
  end

  it 'supports renaming simple properties' do
    expect(represented_object['simple_new_name']).to eq 'simple old property'
  end

  it 'supports renaming derived properties' do
    expect(represented_object['derived_new_name']).to eq 'derived old property'
  end

  it 'supports renaming complex properties' do
    expect(represented_object['complex_new_name']['some_property']).to eq 'some old property'
  end

  it 'supports collections' do
    expect(represented_object['thingies'].size).to eq 2
    expect(represented_object['thingies'][0]['some_property']).to eq 'first'
    expect(represented_object['thingies'][1]['some_property']).to eq 'second'
  end

  it 'supports renaming collections' do
    expect(represented_object['thingies_new_name'].size).to eq 1
    expect(represented_object['thingies_new_name'][0]['some_property']).to eq 'first other'
  end

  it "doesn't crash missing collections" do
    object.thingies = nil
    expect(represented_object['thingies']).to eq []
  end

  it 'supports links' do
    links = represented_object['links']
    expect(links.size).to eq 3
    expect(links[0]['rel']).to eq 'url1'
    expect(links[0]['href']).to eq 'an_url'
    expect(links[0]).to_not have_key 'templated'
    expect(links[1]['rel']).to eq 'url2'
    expect(links[1]['href']).to eq 'another_url'
    expect(links[1]).to_not have_key 'templated'
    expect(links[2]['rel']).to eq 'template'
    expect(links[2]['href']).to eq 'an_url_with{placeholder}'
    expect(links[2]).to have_key 'templated'
    expect(links[2]['templated']).to eq true
  end

  it "doesn't have to have links" do
    representer = Module.new { include Betterdocs::Representer }
    represented_object = JSON(representer.apply(object).to_json)
    expect(represented_object['links']).to eq []
  end

  it 'supports conditional properties' do
    expect(represented_object['if_no']).to be_nil
    expect(represented_object['unless_yes']).to be_nil
    expect(represented_object['if_predicate']).to be_nil
    expect(represented_object['unless_predicate']).to be_nil
  end
end
