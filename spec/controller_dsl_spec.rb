require 'spec_helper'

describe 'controller dsl' do
  let :docs do
    Betterdocs::ControllerCollector.new
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
      Betterdocs.stub(:rails).should_return
      my_controller = docs.controller
      my_controller.should be_present
      my_controller.name.should eq :my_test
      my_controller.section.should eq :test_section
      my_controller.controller.should eq controller
      my_controller.description.should eq 'my description'
      my_controller.url.should eq ''
    end
  end

#  context 'link' do
#    it "cannot add a new link without url" do
#      expect {
#        docs.add_element representer, :link, 'my_link', some_option: true do
#        end
#      }.to raise_error(ArgumentError)
#    end
#
#    it "can add a new link" do
#      docs.add_element representer, :link, 'my_link', some_option: true do
#        description 'my URL description'
#        url         'http://foo.bar'
#      end
#      link = docs.link(:my_link)
#      link.should be_present
#      link.name.should eq :my_link
#      link.representer.should eq representer
#      link.description.should eq 'my URL description'
#      link.options.should include(some_option: true)
#    end
#
#    it "can define a link"
#  end
end
