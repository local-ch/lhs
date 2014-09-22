require 'rails_helper'

describe LHS::Data do

  let(:data_from_raw) do
    LHS::Data.new(
      href: 'http://www.local.ch/v2/stuff',
      id: '123123123'
    )
  end

  let(:data_from_link) do
    LHS::Data.new(
      LHS::Link.new(
        'http://www.local.ch/v2/stuff',
        LHS::Data.new(
          href: 'http://www.local.ch/v2/stuff'
        )
      )
    )
  end

  context 'raw' do

    it 'you can access raw data that is underlying' do
      expect(data_from_raw._raw_).to be_kind_of Hash
    end

    it 'forwards raw when you feed data with some LHS object' do
      expect(data_from_link._raw_).to be_kind_of Hash
      expect(data_from_link._raw_).to eq(
        href: 'http://www.local.ch/v2/stuff'
      )
    end
  end
end
