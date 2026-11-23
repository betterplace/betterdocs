describe Betterdocs::JsonParamsRepresenterCollector do
  let :collector do
    described_class.new
  end

  describe '#initialize' do
    it 'starts with an empty params hash' do
      expect(collector.params).to eq({})
    end
  end

  describe '#param' do
    it 'returns nil for an unknown param name' do
      expect(collector.param(:nonexistent)).to be_nil
    end

    it 'returns the stored param for a known name' do
      collector.add_element('MyRep', :param, :email) do
        description 'An email address'
        types String
      end
      param = collector.param(:email)
      expect(param).to be_a Betterdocs::Dsl::JsonParams::Param
      expect(param.description).to eq 'An email address'
    end
  end

  describe '#add_element' do
    it 'stores a Param element keyed by its name' do
      collector.add_element('MyRep', :param, :email) do
        description 'An email'
        types String
      end
      expect(collector.params.keys).to eq [ :email ]
    end

    it 'raises ArgumentError for an unknown element type' do
      expect {
        collector.add_element('MyRep', :widget, :foo)
      }.to raise_error(ArgumentError,
                       /unknown documentation element type :widget/)
    end
  end

  describe '#representer' do
    it 'returns nil when the collector is empty' do
      expect(collector.representer).to be_nil
    end

    it 'returns the representer of the first param that has one' do
      collector.add_element('MyRep', :param, :email) do
        description 'An email'
        types String
      end
      expect(collector.representer).to eq 'MyRep'
    end
  end

  describe '#to_s' do
    it 'renders a header with no properties when empty' do
      expect(collector.to_s).to eq "***  ***\n"
    end

    it 'lists documented params with types and descriptions' do
      collector.add_element('MyRep', :param, :email) do
        description 'An email address'
        types String
      end
      collector.add_element('MyRep', :param, :age) do
        description 'User age'
        types Integer
      end
      output = collector.to_s
      expect(output).to start_with "*** MyRep ***\n"
      expect(output).to include "\nProperties:"
      expect(output).to include "email: (string): An email address"
      expect(output).to include "age: (number): User age"
    end
  end
end
