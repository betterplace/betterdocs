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
    links.should have(3).entries
    links[0]['rel'].should eq 'url1'
    links[0]['href'].should eq 'an_url'
    links[0].should_not have_key 'templated'
    links[1]['rel'].should eq 'url2'
    links[1]['href'].should eq 'another_url'
    links[1].should_not have_key 'templated'
    links[2]['rel'].should eq 'template'
    links[2]['href'].should eq 'an_url_with{placeholder}'
    links[2].should have_key 'templated'
    links[2]['templated'].should eq true
  end

  it "doesn't have to have links" do
    representer = Module.new { include Betterdocs::Representer }
    represented_object = JSON(representer.apply(object).to_json)
    represented_object['links'].should eq []
  end

  it 'supports conditional properties' do
    represented_object['if_no'].should be_nil
    represented_object['unless_yes'].should be_nil
    represented_object['if_predicate'].should be_nil
    represented_object['unless_predicate'].should be_nil
  end
end
