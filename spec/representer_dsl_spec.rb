require 'spec_helper'

describe 'representer dsl' do
  let :docs do
    Betterdocs::RepresenterCollector.new
  end

  let :representer do
    Module.new do
      def self.property(*)
        @property_set = true
      end

      def self.has_property_set?
        @property_set
      end

      def self.link(*)
        @link_set = true
      end

      def self.has_link_set?
        @link_set
      end

      def self.to_s
        'MyRepresenter'
      end
    end
  end

  it "cannot add unknown element types" do
    expect {
      docs.add_element representer, :foobar, 'my_foobar' do
      end
    }.to raise_error(ArgumentError)
  end

  context 'property' do
    it "can add a new property" do
      docs.add_element representer, :api_property, 'my_property', some_option: true do
        as          :foo_bar
        description 'my description'
        types       [ String, nil ]
      end
      property = docs.api_property(:my_property)
      property.should be_present
      property.name.should eq :my_property
      property.representer.should eq representer
      property.description.should eq 'my description'
      property.options.should include(some_option: true)
      property.types.should eq %w[ String NilClass ]
      property.example.should eq 'TODO' # TODO
      property.options.should include(as: :foo_bar)
    end

    it "can define a property on representer" do
      docs.add_element representer, :api_property, 'my_property', some_option: true do
      end
      property = docs.api_property(:my_property)
      property.should be_present
      property.define
      representer.should have_property_set
    end
  end

  context 'link' do
    it "cannot add a new link without url" do
      expect {
        docs.add_element representer, :api_link, 'my_link', some_option: true do
        end
      }.to raise_error(ArgumentError)
    end

    it "can add a new link" do
      docs.add_element representer, :api_link, 'my_link', some_option: true do
        description 'my URL description'
        url         'http://foo.bar'
      end
      link = docs.api_link(:my_link)
      link.should be_present
      link.name.should eq :my_link
      link.representer.should eq representer
      link.description.should eq 'my URL description'
      link.options.should include(some_option: true)
    end

    it "can define a link on representer" do
      docs.add_element representer, :api_link, 'my_link', some_option: true do
        description 'my URL description'
        url         'http://foo.bar'
      end
      link = docs.api_link(:my_link)
      link.should be_present
      link.define
      representer.should have_link_set
    end
  end

  it 'can return a string representation of all its links/properties' do
    pending
    docs.add_element representer, :api_property, 'my_property', some_option: true do
      as          :foo_bar
      description 'my description'
      types       [ String, nil ]
    end
    docs.add_element representer, :api_property, 'my_property2', some_option: true do
      description 'my description2'
      types       [ true, false ]
    end
    docs.add_element representer, :api_link, 'my_link', some_option: true do
      description 'my URL description'
      url         'http://foo.bar'
    end
    docs.add_element representer, :api_link, 'my_link2', some_option: true do
      description 'my URL description2'
      url         'http://foo.baz'
    end
    docs.to_s.should eq <<EOT
Representer: Foo

Properties:
my_property (String|NilClass): my description

my_property2 (TrueClass|FalseClass): my description2

Links:
my_link (http://foo.bar) my URL description

my_link2 (http://foo.baz) my URL description2
EOT
  end
end
