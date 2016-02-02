require 'rails_helper'

describe LHS::Data do
  let(:raw) do
    { labels: { de: ['cat', 'dog'] } }
  end

  let(:data) do
    described_class.new(raw)
  end

  context 'select' do
    it 'works with select' do
      expect(
        data.labels.de.select { |x| x }.join
      ).to eq 'catdog'
    end
  end
end
