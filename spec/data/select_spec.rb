require 'rails_helper'

describe LHS::Data do
  let(:raw) do
    { labels: { de: ['cat', 'dog'] } }
  end

  let(:data) do
    LHS::Data.new(raw, nil, Record)
  end

  before(:each) do
    class Record < LHS::Record
      endpoint '{+datastore}/v2/data'
    end
  end

  context 'select' do
    it 'works with select' do
      expect(
        data.labels.de.select { |x| x }.join
      ).to eq 'catdog'
    end
  end
end
