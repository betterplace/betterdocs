require 'spec_helper'

describe Betterdocs::Dsl::Result::Property do
  let :result do
    {}
  end

  let :representer do
    double('Betterdocs::ResultRepresenter')
  end

  context 'mostly default values' do
    let :property do
      described_class.new(representer, 'test', {})
    end

    it 'has a name' do
      expect(property.name).to eq :test
    end

    it 'has a description' do
      expect(property.description).to eq 'TODO'
    end

    it 'has an example' do
      expect(property.example).to eq 'TODO'
    end

    it 'has a types array' do
      expect(property.types).to eq []
    end

    it 'has a sanitize proc' do
      expect(property.sanitize).to be_a Proc
    end

    it 'can be assigned' do
      property.assign(result, double(test: '<p><evil></p>'))
      expect(result['test']).to eq '<p></p>'
    end
  end

  context 'configured values' do
    let :sanitize_proc do
      -> text { text.gsub('<evil>', '') }
    end

    let :property do
      sp = sanitize_proc
      described_class.new(representer, 'test', {}) do
        description 'description'
        example 'example'
        types ''
        sanitize sp
      end
    end

    it 'has a name' do
      expect(property.name).to eq :test
    end

    it 'has a description' do
      expect(property.description).to eq 'description'
    end

    it 'has an example' do
      expect(property.example).to eq 'example'
    end

    it 'has a types array' do
      expect(property.types).to eq %w[ string ]
    end

    it 'has a sanitize proc' do
      expect(property.sanitize).to eq sanitize_proc
    end

    it 'can be assigned' do
      property.assign(result, double(test: '<foo><evil><bar>'))
      expect(result['test']).to eq '<foo><bar>'
    end
  end
end
