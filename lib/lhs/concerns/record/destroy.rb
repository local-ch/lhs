require 'active_support'

class LHS::Record

  module Destroy
    extend ActiveSupport::Concern

    module ClassMethods
      def destroy(args, options = nil)
        options = {} if options.blank?
        params = args.respond_to?(:to_h) ? args : { id: args }
        request(options.merge(params: params, method: :delete))
      end
    end
  end
end
