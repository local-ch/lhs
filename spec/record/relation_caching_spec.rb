# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'cache' do
    let(:transaction) { Transaction.find(1) }
    let(:user) { transaction.user }

    before do
      class Transaction < LHS::Record
        endpoint 'http://myservice/transactions'
        endpoint 'http://myservice/transactions/{id}'
        has_one :user
      end

      class User < LHS::Record
        has_many :comments

        def email
          self[:email_address]
        end
      end

      class Comment < LHS::Record
      end

      [1, 2].each do |id|
        stub_request(:get, "http://myservice/transactions/#{id}")
          .to_return(body: {
            user: {
              email_address: 'steve@local.ch',
              comments: []
            }
          }.to_json)
      end
    end

    it 'caches the relation in memory' do
      allow(LHS::Record).to receive(:for_url).and_return(User)
      user_object_id = transaction.user.object_id
      expect(transaction.user.object_id).to eql(user_object_id)
      transaction2 = Transaction.find(2)
      expect(transaction2.user.object_id).not_to eql(user_object_id)
    end

    it 'recalculates cache for relation when it was modified' do
      allow(LHS::Record).to receive(:for_url).and_return(Comment)
      expect(user.comments).to be_blank
      comments_object_id = user.comments.object_id
      user.comments = [Comment.new]
      expect(user.comments.object_id).not_to eql(comments_object_id)
      expect(user.comments).not_to be_blank
    end
  end

  context 'clear cache' do
    before do
      class Place < LHS::Record
        endpoint 'https://datastore/places/{id}', followlocation: true, headers: { 'Prefer' => 'redirect-strategy=redirect-over-not-found' }
        has_many :available_assets
      end

      class AvailableAsset < LHS::Record
      end

      stub_request(:get, "http://datastore/places/#{place_id}/available-assets?limit=100")
        .to_return(body: {
          total: available_assets.size,
          items: available_assets
        }.to_json)
    end

    let(:place_id) { SecureRandom.urlsafe_base64 }

    let(:place_hash) do
      {
        href: "https://datastore/places/#{place_id}",
        id: place_id,
        available_assets: { href: "http://datastore/places/#{place_id}/available-assets?offset=0&limit=10" }
      }
    end

    let(:available_asset_hash) do
      { asset_code: 'OPENING_HOURS' }
    end

    let(:available_assets) { [available_asset_hash] }

    it 'clears the cache when using find' do
      stub_request(:get, place_hash[:href])
        .to_return(body: place_hash.to_json)
      place = Place
        .options(auth: { bearer: 'XYZ' })
        .includes(:available_assets)
        .find(place_id)
      expect(place.available_assets.first).to be_a(AvailableAsset)
    end

    it 'clears the cache when using where' do
      stub_request(:get, place_hash[:href])
        .to_return(body: place_hash.to_json)
      place = Place
        .options(auth: { bearer: 'XYZ' })
        .includes(:available_assets)
        .where(id: place_id)
      expect(place.available_assets.first).to be_a(AvailableAsset)
    end

    it 'clears the cache when using find_by' do
      stub_request(:get, "https://datastore/places/#{place_id}?limit=1")
        .to_return(body: place_hash.to_json)
      place = Place
        .options(auth: { bearer: 'XYZ' })
        .includes(:available_assets)
        .find_by(id: place_id)
      expect(place.available_assets.first).to be_a(AvailableAsset)
    end
  end

end
