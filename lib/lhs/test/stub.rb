# frozen_string_literal: true

require 'local_uri'
require 'webmock'
module LHS
  module Test
    class Stub
      extend WebMock::API
      DEFAULT_LIMIT = LHS::Pagination::Base::DEFAULT_LIMIT

      def self.all(url, items, options = {})
        items.each_slice(DEFAULT_LIMIT).with_index do |(*batch), index|
          uri = LocalUri::URI.new(url)
          uri.query.merge!(limit: DEFAULT_LIMIT)
          uri.query.merge!(offset: DEFAULT_LIMIT * index) unless index.zero?
          stub_request(:get, uri.to_s)
            .with(options)
            .to_return(
              body: {
                items: batch,
                offset: index * DEFAULT_LIMIT,
                total: items.length
              }.to_json
            )
        end
      end
    end
  end
end
