require 'spec_helper'

RSpec.describe Betterdocs::Dsl::Representer::JsonTypeMapper do
  let :jtm do Betterdocs::Dsl::Representer::JsonTypeMapper end

  it "derives json types" do
    expect(jtm.derive_json_type_from(true)).to eq 'boolean'
    expect(jtm.derive_json_type_from(TrueClass)).to eq 'boolean'
    expect(jtm.derive_json_type_from(false)).to eq 'boolean'
    expect(jtm.derive_json_type_from(FalseClass)).to eq 'boolean'
    expect(jtm.derive_json_type_from(nil)).to eq 'null'
    expect(jtm.derive_json_type_from(NilClass)).to eq 'null'
    expect(jtm.derive_json_type_from(42)).to eq 'number'
    expect(jtm.derive_json_type_from(Fixnum)).to eq 'number'
    expect(jtm.derive_json_type_from(42)).to eq 'number'
    expect(jtm.derive_json_type_from(Fixnum)).to eq 'number'
    expect(jtm.derive_json_type_from(Math::PI)).to eq 'number'
    expect(jtm.derive_json_type_from(Float)).to eq 'number'
    expect(jtm.derive_json_type_from([])).to eq 'array'
    expect(jtm.derive_json_type_from(Array)).to eq 'array'
    expect(jtm.derive_json_type_from({})).to eq 'object'
    expect(jtm.derive_json_type_from(Hash)).to eq 'object'
    expect(jtm.derive_json_type_from('foo')).to eq 'string'
    expect(jtm.derive_json_type_from(String)).to eq 'string'
  end

  it "maps arrays of ruby types correctly" do
    expect(jtm.map_types([])).to eq %w[ array ]
    expect(jtm.map_types([ [] ])).to eq %w[ array ]
    expect(jtm.map_types([ [], {}, Array, nil, Hash ])).to eq %w[ array null object ]
    expect(jtm.map_types("foo")).to eq %w[ string ]
  end
end
