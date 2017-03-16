require 'spec_helper'

describe Betterdocs::Generator::Markdown do
  let :rails do
    double(
      root: Pathname.pwd + 'spec/assets',
      env: double(development?: true),
      configuration: double.as_null_object,
      application:   double.as_null_object
    )
  end

  before do
    allow(Betterdocs).to receive(:rails).and_return rails
    ComplexConfig::Provider.config_dir = 'spec/assets/config'
    Betterdocs::Global.configure
  end

  let :generator do
    described_class.new
  end

  let :output_directory do
    Dir.mktmpdir('api_docs')
  end

  before do
    allow(generator.config).to receive(:output_directory).and_return output_directory
  end

  it 'can be instantiated' do
    expect(generator).to be_a described_class
  end

  it 'can generate' do
    dirname = generator.config.output_directory
    expect(generator).to receive(:generate_to).with(dirname).and_call_original
    expect(generator).to receive(:configure_for_creation).and_call_original
    expect(generator).to receive(:prepare_dir).with(dirname).and_call_original
    expect(generator).to receive(:create_sections).with(dirname).and_call_original
    expect(generator).to receive(:create_readme).with(dirname).and_call_original
    expect(generator).to receive(:create_assets).and_call_original
    expect(generator.generate).to eq generator
  end
end
