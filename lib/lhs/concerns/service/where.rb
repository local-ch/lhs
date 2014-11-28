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

        # add bookmark to hash
        bookmark = params.find { |p| p.is_a?(Symbol) }
        merged_hash[:__bookmark__] = bookmark if bookmark
        merged_hash
      end
    end
  end
end
