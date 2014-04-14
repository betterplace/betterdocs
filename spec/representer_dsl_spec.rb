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
      docs.add_element representer, :property, 'my_property' do
        # XXX as          :foo_bar
        description 'my description'
        types       [ String, nil ]
      end
      property = docs.property(:my_property)
      property.should be_present
      property.name.should eq :my_property
      property.representer.should eq representer
      property.description.should eq 'my description'
      property.types.should eq %w[ null string ]
      property.example.should eq 'TODO' # TODO
    end

    it "can define a property on representer" do
      docs.add_element representer, :property, 'my_property' do
      end
      property = docs.property(:my_property)
      property.should be_present
    end
  end

  context 'link' do
    it "cannot add a new link without url" do
      docs.add_element representer, :link, 'my_link' do
      end
      link = docs.link(:my_link)
      expect { link.url }.to raise_error(ArgumentError)
    end

    it "can add a new link" do
      docs.add_element representer, :link, 'my_link' do
        description 'my URL description'
        url         { 'http://foo.bar' }
      end
      link = docs.link(:my_link)
      link.should be_present
      link.name.should eq :my_link
      link.representer.should eq representer
      link.description.should eq 'my URL description'
    end

    it "can define a link on representer" do
      docs.add_element representer, :link, 'my_link' do
        description 'my URL description'
        url         { 'http://foo.bar' }
      end
      link = docs.link(:my_link)
      link.should be_present
    end
  end

  it 'can return a string representation of all its links/properties' do
    docs.add_element representer, :property, 'my_property' do
      # XXX as          :foo_bar
      description 'my description'
      types       [ String, nil ]
    end
    docs.add_element representer, :property, 'my_property2' do
      description 'my description2'
      types       [ true, false ]
    end
    docs.add_element representer, :link, 'my_link' do
      description 'my URL description'
      url         { 'http://foo.bar' }
    end
    docs.add_element representer, :link, 'my_link2' do
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
    module Location
      include Betterdocs::Representer

      property :latitude

      property :longitude

      link :dot do
        url { 'http://foo.bar/dot' }
      end
    end

    module Address
      include Betterdocs::Representer

      property :city

      property :location do
        represent_with Location
      end

      link :map do
        url { 'http://foo.bar/map' }
      end
    end


    module Person
      include Betterdocs::Representer

      property :name

      property :address do
        represent_with Address
      end

      link :self do
        url { 'http://foo.bar' }
      end
    end

    it 'can return an array of its nested properties' do
      Person.docs.nested_properties.should have(6).entries
      Person.docs.nested_properties.map(&:full_name).should eq [ "name",
        "address", "address.city", "address.location",
        "address.location.latitude", "address.location.longitude" ]
    end

    it 'can return an array of its nested links' do
      Person.docs.nested_links.should have(3).entries
      Person.docs.nested_links.map(&:full_name).should eq [
        "self", "address.map", "address.location.dot" ]
    end
  end
end
