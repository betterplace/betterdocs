require 'spec_helper'

describe Betterdocs::Dsl::Property do
  let(:object) { double('object without name').as_null_object }

  let(:property) { Betterdocs::Dsl::Property.new(object, :name, {}) }

  describe '#assign?' do
    it 'returns false if the given if proc returns false' do
      property = Betterdocs::Dsl::Property.new(Object, :name, { if: -> { false } })
      property.assign?(object).should be_false
    end

    it 'returns false if the given unless proc returns true' do
      property = Betterdocs::Dsl::Property.new(Object, :name, { unless: -> { true } })
      property.assign?(object).should be_false
    end

    it 'returns true if nothing speaks against it' do
      property.assign?(object).should be_true
    end
  end

  describe '#assign' do
    it 'returns false if the attribute value name is nil' do
      r = {}
      property.assign(r, object)
      r.should_not be_key :foo
    end
  end
end
