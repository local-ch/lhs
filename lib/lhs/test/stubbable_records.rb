# frozen_string_literal: true

require 'local_uri'
require 'webmock'

class LHS::Record
  DEFAULT_LIMIT = LHS::Pagination::Base::DEFAULT_LIMIT

  def self.stub_all(url, items, options = {})
    extend WebMock::API

    items.each_slice(DEFAULT_LIMIT).with_index do |(*batch), index|
      uri = LocalUri::URI.new(url)
      uri.query.merge!(
        limit_key(:parameter) => DEFAULT_LIMIT
      )
      offset = pagination_class.page_to_offset(index+1, DEFAULT_LIMIT)
      uri.query.merge!(
        pagination_key(:parameter) => offset
      ) unless index.zero?
      request_stub = stub_request(:get, uri.to_s)
      request_stub.with(options) if options.present?
      request_stub.to_return(
        body: {
          items: batch,
          offset: index.zero? ? 0 : offset,
          total: items.length
        }.to_json
      )
    end
  end
end
