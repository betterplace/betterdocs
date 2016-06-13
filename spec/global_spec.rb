require 'spec_helper'
require 'pathname'

RSpec.describe Betterdocs::Global do
  let :rails do
    double(
      root: Pathname.pwd + 'spec/assets',
      env: double(development?: true)
    )
  end

  before do
    allow(Betterdocs).to receive(:rails).and_return rails
    ComplexConfig::Provider.config_dir = 'spec/assets/config'
    Betterdocs::Global.configure
  end

  it 'has a project name' do
    expect(Betterdocs::Global.project_name).to eq 'My Example Project'
  end

  it 'uses an api prefix' do
    expect(Betterdocs::Global.api_prefix).to eq 'api'
  end

  it 'returns all api controllers via wild matching' do
    expect(Betterdocs::Global.api_controllers.size).to eq 1
    expect(Betterdocs::Global.api_controllers.last).to end_with\
      'spec/assets/app/controllers/api/foos_controller.rb'
  end

  context 'platform url' do
    before do
      Betterdocs::Global.platform_protocol 'http'
      Betterdocs::Global.platform_host 'localhost:3000'
    end

    it 'has default platform_url' do
      expect(Betterdocs::Global.platform_url).to eq 'http://localhost:3000'
    end

    it 'can parse platform_url' do
      Betterdocs::Global.platform_url 'https://foo.bar:1234'
      expect(Betterdocs::Global.platform_url).to eq 'https://foo.bar:1234'
      Betterdocs::Global.platform_url 'https://foo.bar'
      expect(Betterdocs::Global.platform_url).to eq 'https://foo.bar:443'
      Betterdocs::Global.platform_url 'http://foo.bar'
      expect(Betterdocs::Global.platform_url).to eq 'http://foo.bar:80'
    end

    it 'has platform_protocol' do
      expect(Betterdocs::Global.platform_protocol).to eq 'http'
    end

    it 'has platform_host' do
      expect(Betterdocs::Global.platform_host).to eq 'localhost:3000'
    end
  end

  context 'api url' do
    before do
      Betterdocs::Global.api_protocol 'http'
      Betterdocs::Global.api_host 'localhost:3000'
    end

    it 'has default api_url' do
      expect(Betterdocs::Global.api_url).to eq 'http://localhost:3000'
    end

    it 'can parse api_url' do
      Betterdocs::Global.api_url 'https://foo.bar:1234'
      expect(Betterdocs::Global.api_url).to eq 'https://foo.bar:1234'
      Betterdocs::Global.api_url 'https://foo.bar'
      expect(Betterdocs::Global.api_url).to eq 'https://foo.bar:443'
      Betterdocs::Global.api_url 'http://foo.bar'
      expect(Betterdocs::Global.api_url).to eq 'http://foo.bar:80'
    end

    it 'has api_protocol' do
      expect(Betterdocs::Global.api_protocol).to eq 'http'
    end

    it 'has api_host' do
      expect(Betterdocs::Global.api_host).to eq 'localhost:3000'
    end

    it 'can return api_base_url' do
      Betterdocs::Global.api_url 'https://foo.bar:1234'
      expect(Betterdocs::Global.api_base_url).to eq 'https://foo.bar:1234/api'
    end

  end

  context 'asset url' do
    before do
      Betterdocs::Global.asset_protocol 'http'
      Betterdocs::Global.asset_host 'localhost:3000'
    end

    it 'has default asset_url' do
      expect(Betterdocs::Global.asset_url).to eq 'http://localhost:3000'
    end

    it 'can parse asset_url' do
      Betterdocs::Global.asset_url 'https://foo.bar:1234'
      expect(Betterdocs::Global.asset_url).to eq 'https://foo.bar:1234'
      Betterdocs::Global.asset_url 'https://foo.bar'
      expect(Betterdocs::Global.asset_url).to eq 'https://foo.bar:443'
      Betterdocs::Global.asset_url 'http://foo.bar'
      expect(Betterdocs::Global.asset_url).to eq 'http://foo.bar:80'
    end

    it 'has asset_protocol' do
      expect(Betterdocs::Global.asset_protocol).to eq 'http'
    end

    it 'has asset_host' do
      expect(Betterdocs::Global.asset_host).to eq 'localhost:3000'
    end
  end

  it 'has api_default_format' do
    expect(Betterdocs::Global.api_default_format).to eq 'json'
  end

  it 'can return api_url_options' do
    expect(Betterdocs::Global.api_url_options).to eq(
      protocol: "https",
      host:     "api.example.com:3000",
      format:   "json"
    )
  end

  it 'has templates_directory' do
    expect(Betterdocs::Global.templates_directory).to\
      eq 'documentation/templates'
  end

  it 'has output_directory' do
    expect(Betterdocs::Global.output_directory).to eq 'api_docs'
  end

  it 'has publish_git' do
    expect(Betterdocs::Global.publish_git).to eq 'git@github.com:foo/bar.git'
  end

  it 'can ignore in the git repo' do
    expect(Betterdocs::Global.ignore).to eq %w[ .DS_Store ]
  end

  context 'assets' do
    it 'can have assets' do
      expect(Betterdocs::Global.assets).to be_a Hash
      expect(Betterdocs::Global.assets).not_to be_empty
    end

    it 'can set assets' do
      begin
        Betterdocs::Global.assets = { foo: 'bar' }
        expect(Betterdocs::Global.assets).to eq({ 'foo' => 'bar' })
        Betterdocs::Global.asset :bar, to: 'baz'
        expect(Betterdocs::Global.assets).to eq({ 'foo' => 'bar', 'bar' => 'baz' })
        Betterdocs::Global.asset 'quux'
        expect(Betterdocs::Global.assets).to eq({ 'foo' => 'bar', 'bar' => 'baz', 'quux' => :root })
      ensure
        Betterdocs::Global.assets.clear
      end
    end

    it 'can iterate over assets' do
      expect { |b| Betterdocs::Global.each_asset(&b) }.to\
        yield_successive_args(
          ["app/views/api_v4/documentation/assets/CHANGELOG.md", "api_docs/CHANGELOG.md"],
          ["app/assets/images/logos/logo.png", "api_docs/images/logo.png"]
        )
    end
  end

  it 'has a default configuration_file' do
    expect(Betterdocs::Global.configuration_file).to\
      be_a ComplexConfig::Settings
  end

  it 'all_docs' do
    load 'spec/assets/app/controllers/api/foos_controller.rb'
    expect(Api::FoosController).to receive(:docs).and_return :foo
    expect(Betterdocs::Global.all_docs).to eq [ :foo ]
  end
end
