require 'spec_helper'

describe Betterdocs::Dsl::Result::Link do
  let :result do
    {
      'links' => []
    }
  end

  let :representer do
    double('Betterdocs::ResultRepresenter')
  end

  context 'mostly default values' do
    let :link do
      described_class.new(representer, 'test', {}) do
        url { :url }
      end
    end

    it 'has a name' do
      expect(link.name).to eq :test
    end

    it 'has a description' do
      expect(link.description).to eq 'TODO'
    end

    it 'has an templated predicate' do
      expect(link.templated).to eq false
    end

    it 'has an url block' do
      expect(link.url).to be_a Proc
      expect(link.url.()).to eq :url
    end

    it 'can be assigned' do
      link.assign(result, double(test: '<foo><evil><bar>'))
      expect(result['links']).to eq [ { 'rel' => 'test', 'href' => 'url' } ]
    end
  end
end
