require 'spec_helper'

describe Betterdocs::Dsl::Controller::Action::Response do
  let :docs do
    double(
      'Betterdocs::ResultRepresenterCollector',
      nested_links: :links,
      nested_properties: :properties
    )
  end

  let :representer do
    double('Representer', docs: docs)
  end

  let :result_data do
    double(
      'Result',
      representer: representer,
      to_hash: { data: %w[ fake-it ] }
    )
  end

  let :response do
    data = result_data
    object = described_class.new do
      data
    end
    allow(object).to receive(:controller).and_return('TheController')
    allow(object).to receive(:action).and_return('in_action')
    object
  end

  let :param_value do
    double('Betterdocs::Dsl::Controller::Action::Param', value: 'foo')
  end

  it 'has params' do
    allow(response).to receive(:param).with(:test).and_return param_value
    expect(response.params[:test]).to eq 'foo'
  end

  it 'complains about missing data in example responses' do
    allow(result_data).to receive(:to_hash).and_return('data' => [])
    expect { response.data }.to raise_error(Betterdocs::Dsl::Controller::Action::Response::Error)
  end

  it 'has data' do
    expect(response.data).to eq result_data
  end

  it 'has properties' do
    expect(response.properties).to eq :properties
  end

  it 'has links' do
    expect(response.links).to eq :links
  end

  it 'has representer' do
    expect(response.representer).to eq representer
  end

  it 'can be converted into a JSON document' do
    expect(JSON(response.to_json)).to eq("data" => %w[ fake-it ])
  end
end
