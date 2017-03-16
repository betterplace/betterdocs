require 'spec_helper'

describe Betterdocs::Dsl::Result::CollectionProperty do
  let :result do
    {}
  end

  let :representer do
    double('Betterdocs::ResultRepresenter')
  end

  let :sub_representer do
    double(
      'Betterdocs::ResultRepresenter',
      hashify: { 'a' => 'hash' },
      '<': true
    )
  end

  let :property do
    sr = sub_representer
    described_class.new(representer, 'test', {}) do
      represent_with sr
    end
  end

  let :members do
    [ double('Member'), double('Member') ]
  end

  it 'calls representer for every member' do
    property.assign(result, double(test: members))
    expect(result['test']).to eq [
      { 'a' => 'hash' },
      { 'a' => 'hash' },
    ]
  end
end
