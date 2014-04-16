require 'spec_helper'

describe Betterdocs::Dsl::Property do

  describe '#assign?' do
    let(:property) { Betterdocs::Dsl::Property.new(Object, :name, {}) }

    it 'returns false if the given object is nil' do
      property.assign?(nil).should be_false
    end

    it 'returns false if the given if proc returns false' do
      property = Betterdocs::Dsl::Property.new(Object, :name, { if: -> { false } })
      property.assign?(:foo).should be_false
    end

    it 'returns false if the given unless proc returns true' do
      property = Betterdocs::Dsl::Property.new(Object, :name, { unless: -> { true } })
      property.assign?(:foo).should be_false
    end

    it 'returns true if nothing speaks against it' do
      property.assign?(:foo).should be_true
    end
  end

end
