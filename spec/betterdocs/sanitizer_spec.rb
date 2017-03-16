require 'spec_helper'

describe Betterdocs::Sanitizer do
  let :sanitizer do
    described_class.new do |text|
      text.gsub('<evil>', '')
    end
  end

  let :text do
    '<foo><evil><bar>'
  end

  it 'removes evil tags from strings' do
    expect(sanitizer.sanitize(text)).to eq '<foo><bar>'
  end

  it 'ignores other JSON data types' do
    expect(sanitizer.sanitize(nil)).to eq nil
  end

  it 'calls #to_s on the remaining types and sanitizes' do
    expect(sanitizer.sanitize(double(to_s: text))).to eq '<foo><bar>'
  end
end
