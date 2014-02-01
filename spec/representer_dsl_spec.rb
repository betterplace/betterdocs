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

  context 'api_property' do
    it "can add a new property" do
      docs.add_element representer, :api_property, 'my_property', some_option: true do
        # XXX as          :foo_bar
        description 'my description'
        types       [ String, nil ]
      end
      property = docs.api_property(:my_property)
      property.should be_present
      property.name.should eq :my_property
      property.representer.should eq representer
      property.description.should eq 'my description'
      property.options.should include(some_option: true)
      property.types.should eq %w[ null string ]
      property.example.should eq 'TODO' # TODO
      # XXX property.options.should include(as: :foo_bar)
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

  context 'api_link' do
    it "cannot add a new link without url" do
      docs.add_element representer, :api_link, 'my_link' do
      end
      link = docs.api_link(:my_link)
      expect { link.url }.to raise_error(ArgumentError)
    end

    it "can add a new link" do
      docs.add_element representer, :api_link, 'my_link' do
        description 'my URL description'
        url         { 'http://foo.bar' }
      end
      link = docs.api_link(:my_link)
      link.should be_present
      link.name.should eq :my_link
      link.representer.should eq representer
      link.description.should eq 'my URL description'
    end

    it "can define a link on representer" do
      docs.add_element representer, :api_link, 'my_link' do
        description 'my URL description'
        url         { 'http://foo.bar' }
      end
      link = docs.api_link(:my_link)
      link.should be_present
      link.define
      representer.should have_link_set
    end
  end

  it 'can return a string representation of all its links/properties' do
    docs.add_element representer, :api_property, 'my_property', some_option: true do
      # XXX as          :foo_bar
      description 'my description'
      types       [ String, nil ]
    end
    docs.add_element representer, :api_property, 'my_property2', some_option: true do
      description 'my description2'
      types       [ true, false ]
    end
    docs.add_element representer, :api_link, 'my_link' do
      description 'my URL description'
      url         { 'http://foo.bar' }
    end
    docs.add_element representer, :api_link, 'my_link2' do
      description 'my URL description2'
      url         { 'http://foo.baz' }
    end
    docs.to_s.should eq <<EOT
*** MyRepresenter ***

Properties:
my_property: (null|string): my description

my_property2: (boolean): my description2

Links:
my_link: my URL description

my_link2: my URL description2
EOT
  end

  context 'nesting representers' do
    require 'roar/representer/json'
    require 'roar/representer/feature/hypermedia'

    module Location
      include Roar::Representer::JSON
      include Roar::Representer::Feature::Hypermedia
      include Betterdocs::MixIntoRepresenter

      api_property :latitude

      api_property :longitude

      api_link :dot do
        url { 'http://foo.bar/dot' }
      end
    end

    module Address
      include Roar::Representer::JSON
      include Roar::Representer::Feature::Hypermedia
      include Betterdocs::MixIntoRepresenter

      api_property :city

      api_property :location do
        represent_with Location
      end

      api_link :map do
        url { 'http://foo.bar/map' }
      end
    end


    module Person
      include Roar::Representer::JSON
      include Roar::Representer::Feature::Hypermedia
      include Betterdocs::MixIntoRepresenter

      api_property :name

      api_property :address do
        represent_with Address
      end

      api_link :self do
        url { 'http://foo.bar' }
      end
    end

    it 'can return an array of its nested properties' do
      Person.docs.nested_api_properties.should have(6).entries
      Person.docs.nested_api_properties.map(&:full_name).should eq [ "name",
        "address", "address.city", "address.location",
        "address.location.latitude", "address.location.longitude" ]
    end

    it 'can return an array of its nested links' do
      Person.docs.nested_api_links.should have(3).entries
      Person.docs.nested_api_links.map(&:full_name).should eq [
        "self", "address.map", "address.location.dot" ]
    end
  end
end
