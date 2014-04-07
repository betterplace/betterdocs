require 'spec_helper'

describe Betterdocs::Representer do
  module MySubRepresenter
    include Betterdocs::Representer

    property :some_property

    link 'url3' do 'some_url' end
  end

  module MyRepresenter
    include Betterdocs::Representer

    property :simple

    property :derived

    property :complex, represent_with: MySubRepresenter

    property :simple_old_name, as: :simple_new_name

    property :derived_old_name, as: :derived_new_name

    property :complex_old_name, as: :complex_new_name, represent_with: MySubRepresenter

    link 'url1' do 'an_url' end

    link 'url2' do 'another_url' end

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
      p o
      o.complex_old_name.some_property = 'some old property'
    end
  end

  let :object_as_json do
    MyRepresenter.jsonify(object)
  end

  let :represented_object do
    JSON(object_as_json)
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
end
