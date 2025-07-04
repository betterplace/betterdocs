require 'spec_helper'

describe 'controller dsl' do
  let :docs do
    Betterdocs::ControllerCollector.new
  end

  let :rails do
    double(application: double(routes: double(url_for: 'http://foo/bar')))
  end

  let :controller do
    Module.new do
      class << self
        def name
          'MyTestController'
        end

        alias to_s name
      end


      def foo
      end
    end
  end

  it "cannot add unknown element types" do
    expect {
      docs.add_element controller, :foobar, 'my_foobar' do
      end
    }.to raise_error(ArgumentError)
  end

  context 'controller' do
    it "can add a new controller" do
      docs.add_element controller, :controller do
        description 'my description'
        section     :test_section
      end
      allow(Betterdocs).to receive(:rails).and_return rails
      my_controller = docs.controller
      expect(my_controller).to be_present
      expect(my_controller.name).to eq :my_test
      expect(my_controller.section).to eq :test_section
      expect(my_controller.controller).to eq controller
      expect(my_controller.description).to eq 'my description'
      expect(my_controller.url).to eq 'http://foo/bar'
      expect(docs.to_s).to eq(<<EOT)
MyTestController

url: http://foo/bar

my description

===============================================================================

EOT
    end

    it 'can be represented as a string if empty' do
      expect(docs.to_s).to eq(
        "\n===============================================================================\n\n"
      )
    end
  end

  module MyActionJsonParams
    include Betterdocs::JsonParamsRepresenter

    param :baz do
      description 'Some string'
      types       String
      value       'baz'
    end
  end

  SomeParamsTrait = Betterdocs.trait do
    param :quux do
    end
  end

  context 'action' do
    it "can add a new action" do
      docs.add_element controller, :controller do
        description 'my controller description'
        section     :test_section
      end
      docs.add_element controller, :action do
        description 'my description'
        section     :test_section2
        http_method :GET

        param :bar do
        end

        param :baz do
          use_in_url no
        end

        include_params SomeParamsTrait

        json_params_like MyActionJsonParams
      end
      allow(Betterdocs).to receive(:rails).and_return rails
      expect(docs.actions).to be_empty
      docs.configure_current_element(:foo)
      expect(docs.actions.size).to eq 1
      expect(action = docs.action(:foo)).to be_present
      expect(action.controller).to eq controller
      expect(action.name).to eq :foo
      expect(action.section).to eq :test_section2
      expect(docs.section).to eq :test_section
      expect(action.action_method).to eq controller.instance_method(:foo)
      expect(action.http_method).to eq :GET
      expect(action.params).to have_key :bar
      expect(action.params).to have_key :quux
      expect(action.json_params).to have_key :baz
      expect(action.url).to eq 'http://foo/bar'
      expect(docs.to_s.sub(%r(.*(?=spec/)), '')).to eq(<<EOT)
MyTestController

url: http://foo/bar

my controller description

===============================================================================
GET http://foo/bar

MyTestController#foo(bar, baz, quux)

bar(=1): TODO
baz(=2): TODO
quux(=3): TODO

my description

spec/controller_dsl_spec.rb:23

EOT
    end
  end
end
