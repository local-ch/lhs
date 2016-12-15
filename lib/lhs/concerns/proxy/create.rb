require 'active_support'

class LHS::Proxy

  module Create
    extend ActiveSupport::Concern

    def create(data = {}, options = nil)
      record_creation!(options) do
        record_from_link.create(
          data,
          options_for_creation(options)
        )
      end
    end

    def create!(data = {}, options = nil)
      record_creation!(options) do
        record_from_link.create!(
          data,
          options_for_creation(options)
        )
      end
    end

    private

    def record_creation!(options)
      raise(ArgumentError, 'Record already exists') if _raw.keys != [:href] && item?

      record = yield
      # Needed to handle unexpanded collection which looks the same as item
      reload!(options)
      record
    end

    def options_for_creation(options)
      return options if params_from_link.blank?
      options = {} if options.blank?
      options.deep_merge(params: params_from_link)
    end
  end
end
