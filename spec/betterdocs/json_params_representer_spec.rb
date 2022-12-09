require 'spec_helper'

describe Betterdocs::JsonParamsRepresenter do
  module MyJsonParams
    include Betterdocs::JsonParamsRepresenter

    param :string do
      description 'Some string'
      types    String
      value    'peter.paul@betterplace.org'
    end

    param :number do
      description 'some integer number'
      types       Integer
      value       666
      required    yes
    end

    param :flag do
      description 'some boolean flag'
      types       [ true, false ]
      value       true
      required    no
    end
  end

  let :object do
    OpenStruct.new.tap do |o|
      o.string = 'some string'
      o.number = 666
      o.flag   = true
      MyJsonParams.apply(o)
    end
  end

  let :docs do
    MyJsonParams.docs
  end

  it 'can be converted into a ActionController::Parameters instance' do
    expect(object.as_json).to be_a HashWithIndifferentAccess
  end

  it 'it can be turned into a hash' do
    expect(object.as_json).to eq("string" => "some string", "number" => 666, "flag" => true)
  end

  it 'it can be turned into json' do
    expect(object.to_json).to eq '{"string":"some string","number":666,"flag":true}'
  end

  it 'can check a parameter hash' do
    skip
  end

  it 'can return all the documented parameters as a hash' do
    expect(docs.params.keys).to eq %i[ string number flag ]
  end

  context '#param' do
    let :param do
      docs.param(:string)
    end

    it 'can return a single documented parameter' do
      expect(param).to be_a Betterdocs::Dsl::JsonParams::Param
      expect(param.description).to eq 'Some string'
      expect(param.value).to eq 'peter.paul@betterplace.org'
      expect(param.types).to eq %w[ string ]
      expect(param.required).to eq true
    end
  end
end
