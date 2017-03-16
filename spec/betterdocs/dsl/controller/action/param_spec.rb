require 'spec_helper'

describe Betterdocs::Dsl::Controller::Action::Param do
  let :param do
    described_class.new('test') do
      value 666
    end
  end

  it 'has a name' do
    expect(param.name).to eq 'test'
  end

  it 'has a value' do
    expect(param.value).to eq 666
  end

  it 'has a required setting' do
    expect(param.required).to eq true
  end

  it 'has a description' do
    expect(param.description).to eq 'TODO'
  end

  it 'has a use_in_url setting' do
    expect(param.use_in_url).to eq true
  end

  it 'can be displayed as a string' do
    expect(param.to_s).to eq '666'
  end
end

