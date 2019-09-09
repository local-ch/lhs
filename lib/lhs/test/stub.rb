require 'local_uri'
require 'webmock'

module LHS

  def stub
    @stub ||= Stub
  end

  module Test

    class Stub

      def self.all(url, items, options = {})
        items.each_slice(LHS::Pagination::DEFAULT_LIMIT).with_index do |(*batch), index|
        uri = LocalUri::URI.new(url)
        uri.query.merge!(limit: LHS::Pagination::DEFAULT_LIMIT)
        uri.query.merge!(offset: LHS::Pagination::DEFAULT_LIMIT * index) unless index.zero?
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
