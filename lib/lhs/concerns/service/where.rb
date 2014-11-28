require 'active_support'

class LHS::Service

  module Where
    extend ActiveSupport::Concern

    module ClassMethods

      # Used to query data from the service.
      def where(*params)
        params = normalize_parameters(params)
        url = instance.compute_url!(params)
        instance.request(url: url, params: params)
      end

      private

      def normalize_parameters(params)
        # merge all hashes into one
        merged_hash = {}
        params.select { |p| p.is_a?(Hash) }.each do |p|
          merged_hash.merge!(p)
        end

        # add bookmarks to hash
        bookmarks = params.select { |p| p.is_a?(Symbol) }
        merged_hash[:__bookmarks__] = bookmarks if bookmarks.present?
        merged_hash
      end
    end
  end
end
