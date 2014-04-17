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
      def self.to_s
        'MyTestController'
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
      Betterdocs.stub(:rails).and_return rails
      my_controller = docs.controller
      my_controller.should be_present
      my_controller.name.should eq :my_test
      my_controller.section.should eq :test_section
      my_controller.controller.should eq controller
      my_controller.description.should eq 'my description'
      my_controller.url.should eq 'http://foo/bar'
    end
  end
end
