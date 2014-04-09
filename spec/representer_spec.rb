require 'spec_helper'

describe Betterdocs::Representer do
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

    property :complex, represent_with: MySubRepresenter

    property :simple_old_name, as: :simple_new_name

    property :derived_old_name, as: :derived_new_name

    property :complex_old_name, as: :complex_new_name, represent_with: MySubRepresenter

    collection :thingies, represent_with: MySubRepresenter

    collection :other_thingies, as: :thingies_new_name, represent_with: MySubRepresenter

    link 'url1' do
      url { 'an_url' }
    end

    link 'url2' do
      url { 'another_url' }
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
    end
  end

  let :object_as_json do
    MyRepresenter.apply(object).to_json
  end

  let :represented_object do
    JSON(object_as_json)
  end

  it 'can output pretty json' do
    JSON.pretty_generate(MyRepresenter.apply(object)).should include "\n"
  end

  it 'can output ugly json' do
    JSON.generate(MyRepresenter.apply(object)).should_not include "\n"
  end

  it 'supports simple properties' do
    represented_object['simple'].should eq 'simple property'
  end

  it 'supports derived properties' do
    represented_object['derived'].should eq 'derived property'
  end

  it 'supports complex properties' do
    represented_object['complex']['some_property'].should eq 'some property'
  end

  it 'supports renaming simple properties' do
    represented_object['simple_new_name'].should eq 'simple old property'
  end

  it 'supports renaming derived properties' do
    represented_object['derived_new_name'].should eq 'derived old property'
  end

  it 'supports renaming complex properties' do
    represented_object['complex_new_name']['some_property'].should eq 'some old property'
  end

  it 'supports collections' do
    represented_object['thingies'].should have(2).entries
    represented_object['thingies'][0]['some_property'].should eq 'first'
    represented_object['thingies'][1]['some_property'].should eq 'second'
  end

  it 'supports renaming collections' do
    represented_object['thingies_new_name'].should have(1).entry
    represented_object['thingies_new_name'][0]['some_property'].should eq 'first other'
  end

  it "doesn't crash missing collections" do
    object.thingies = nil
    represented_object['thingies'].should eq []
  end

  it 'supports links' do
    links = represented_object['links']
    links.should have(2).entries
    links[0]['rel'].should eq 'url1'
    links[0]['href'].should eq 'an_url'
    links[1]['rel'].should eq 'url2'
    links[1]['href'].should eq 'another_url'
  end

  it "doesn't have to have links" do
    representer = Module.new { include Betterdocs::Representer }
    represented_object = JSON(representer.apply(object).to_json)
    represented_object['links'].should be_nil
  end
end
