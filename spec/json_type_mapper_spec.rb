require 'spec_helper'

describe Betterdocs::JsonTypeMapper do
  let :jtm do Betterdocs::JsonTypeMapper end

  it "should derive json types" do
    jtm.derive_json_type_from(true).should eq 'boolean'
    jtm.derive_json_type_from(TrueClass).should eq 'boolean'
    jtm.derive_json_type_from(false).should eq 'boolean'
    jtm.derive_json_type_from(FalseClass).should eq 'boolean'
    jtm.derive_json_type_from(nil).should eq 'null'
    jtm.derive_json_type_from(NilClass).should eq 'null'
    jtm.derive_json_type_from(42).should eq 'number'
    jtm.derive_json_type_from(Fixnum).should eq 'number'
    jtm.derive_json_type_from(42).should eq 'number'
    jtm.derive_json_type_from(Fixnum).should eq 'number'
    jtm.derive_json_type_from(Math::PI).should eq 'number'
    jtm.derive_json_type_from(Float).should eq 'number'
    jtm.derive_json_type_from([]).should eq 'array'
    jtm.derive_json_type_from(Array).should eq 'array'
    jtm.derive_json_type_from({}).should eq 'object'
    jtm.derive_json_type_from(Hash).should eq 'object'
    jtm.derive_json_type_from('foo').should eq 'string'
    jtm.derive_json_type_from(String).should eq 'string'
  end

  it "should map arrays of ruby types correctly" do
    jtm.map_types([]).should eq %w[ array ]
    jtm.map_types([ [] ]).should eq %w[ array ]
    jtm.map_types([ [], {}, Array, nil, Hash ]).should eq %w[ array null object ]
    jtm.map_types("foo").should eq %w[ string ]
  end
end
