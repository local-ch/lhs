# frozen_string_literal: true

require 'rails_helper'
require 'webrick'

describe LHS::Record do

  before do
    class User < LHS::Record
      endpoint 'http://example.com/users'
      configuration(
        limit_key: 'limit',
        items_key: 'items',
        pagination_strategy: 'link'
      )
    end
  end

  context 'explicit pagination parameters for retrieving pages' do
    it 'uses explicit parameters when retrieving pages' do
      stub_request(:get, "http://example.com/users?limit=100")
        .to_return(body: {
          items: 100.times.map { |_| { name: WEBrick::Utils.random_string(10) } },
          limit: 100,
          next: { href: 'http://example.com/users?from_user_id=100&limit=100' }
        }.to_json)

      stub_request(:get, 'http://example.com/users?from_user_id=100&limit=100')
        .to_return(body: {
          items: 3.times.map { |_| { name: WEBrick::Utils.random_string(10) } },
          limit: 100,
          next: { href: 'http://example.com/users?from_user_id=200&limit=100' }
        }.to_json)

      stub_request(:get, 'http://example.com/users?from_user_id=200&limit=100')
        .to_return(body: {
          items: [],
          limit: 100
        }.to_json)

      users = User.all.fetch
      expect(users.total).to eq 103
      expect(users.count).to eq 103
    end
  end
end
