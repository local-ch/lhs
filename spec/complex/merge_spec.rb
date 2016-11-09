require 'rails_helper'

describe LHS::Complex do
  it 'returns nil when result is empty' do
    expect(LHS::Complex.merge([])).to be_nil
  end

  it 'forwards primitive types' do
    expect(LHS::Complex.merge(entry_id: 123)).to eq(entry_id: 123)
  end

  it 'fails when trying to merge primitive types' do
    expect {
      LHS::Complex.merge([{ entry: true }, { entry: :content }])
    }.to raise_error(ArgumentError)
  end

  context 'first level' do
    context 'merges symbols into/with X' do
      it 'merges symbols into hash' do
        expect(LHS::Complex.merge([
          { entries: :contract },
          :entries
        ])).to eq(entries: :contract)
      end

      it 'merges symbols into array' do
        expect(LHS::Complex.merge([
          [:contracts],
          :entries
        ])).to eq([:contracts, :entries])
        expect(LHS::Complex.merge([
          [:entries],
          :entries
        ])).to eq(:entries)
      end

      it 'merges symbols with symbols' do
        expect(LHS::Complex.merge([
          :contracts,
          :entries
        ])).to eq([:contracts, :entries])
        expect(LHS::Complex.merge([
          :entries,
          :entries
        ])).to eq(:entries)
      end
    end

    context 'merges arrays into/with X' do
      it 'merges arrays into an hash' do
        expect(LHS::Complex.merge([
          { entries: :contract },
          [:entries]
        ])).to eq(entries: :contract)
        expect(LHS::Complex.merge([
          { entries: :contract },
          [:products]
        ])).to eq([{ entries: :contract }, :products])
      end

      it 'merges arrays into an arrays' do
        expect(LHS::Complex.merge([
          [:entries],
          [:entries]
        ])).to eq(:entries)
        expect(LHS::Complex.merge([
          [:entries],
          [:products]
        ])).to eq([:entries, :products])
      end

      it 'merges arrays into an symbols' do
        expect(LHS::Complex.merge([
          :entries,
          [:entries]
        ])).to eq(:entries)
        expect(LHS::Complex.merge([
          :entries,
          [:products]
        ])).to eq([:entries, :products])
      end
    end

    context 'merges hashes into/with X' do
      it 'merges hash into an hash' do
        expect(LHS::Complex.merge([
          { entries: :contract },
          { entries: :products }
        ])).to eq(entries: [:contract, :products])
        expect(LHS::Complex.merge([
          { entries: :contract },
          { entries: :contract }
        ])).to eq(entries: :contract)
      end

      it 'merges hash into an array' do
        expect(LHS::Complex.merge([
          [:entries],
          { entries: :products }
        ])).to eq(entries: :products)
        expect(LHS::Complex.merge([
          [{ entries: :contract }],
          { entries: :contract }
        ])).to eq(entries: :contract)
      end

      it 'merges hash into a symbol' do
        expect(LHS::Complex.merge([
          :entries,
          { entries: :products }
        ])).to eq(entries: :products)
        expect(LHS::Complex.merge([
          :products,
          { entries: :contract }
        ])).to eq([:products, { entries: :contract }])
      end
    end

    context 'merges array into/with X' do
      it 'merges array into hash' do
        expect(LHS::Complex.merge([
          { entries: :contract },
          [:entries, :products]
        ])).to eq([{ entries: :contract }, :products])
      end

      it 'merges array into array' do
        expect(LHS::Complex.merge([
          [:contracts],
          [:entries, :products, :contracts]
        ])).to eq([:contracts, :entries, :products])
      end

      it 'merges array with symbols' do
        expect(LHS::Complex.merge([
          :contracts,
          [:entries, :products]
        ])).to eq([:contracts, :entries, :products])
      end
    end
  end

  context 'multi-level' do
    it 'merges a complex multi-level example' do
      expect(LHS::Complex.merge([
        :contracts,
        [:entries, products: { content_ads: :address }],
        products: { content_ads: { place: :location } }
      ])).to eq([
        :contracts,
        :entries,
        products: { content_ads: [:address, { place: :location }] }
      ])
    end

    it 'merges another complex multi-level example' do
      expect(LHS::Complex.merge([
        [entries: :content_ads, products: :price],
        [:entries, products: { content_ads: :address }],
        [entries: { content_ads: :owner }, products: [{ price: :region }, :image, { content_ads: :owner }]]
      ])).to eq(
        entries: { content_ads: :owner },
        products: [{ content_ads: [:address, :owner], price: :region }, :image]
      )
    end

    it 'merges another complex multi-level example' do
      expect(LHS::Complex.merge([
        { entries: :products },
        { entries: [:customer, :contracts] }
      ])).to eq(
        entries: [:products, :customer, :contracts]
      )
    end

    it 'merges another complex multi-level example' do
      expect(LHS::Complex.merge([
        { entries: { customer: :contracts } },
        { entries: [:customer, :content_ads] }
      ])).to eq(
        entries: [{ customer: :contracts }, :content_ads]
      )
    end

    it 'reduces properly' do
      expect(LHS::Complex.merge([
        [:entries, :place, :content_ads], [{ place: :content_ads }], { content_ads: :place }
      ])).to eq(
        [:entries, { place: :content_ads, content_ads: :place }]
      )
    end
  end
end
