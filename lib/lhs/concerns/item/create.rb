require 'active_support'

class LHS::Item < LHS::Proxy

  module Create
    extend ActiveSupport::Concern

    def create(data = {}, options = nil)
      record_creation! do
        record_from_link.create(
          data,
          options_for_creation(options)
        )
      end
    end

    def create!(data = {}, options = nil)
      record_creation! do
        record_from_link.create!(
          data,
          options_for_creation(options)
        )
      end
    end

    private

    def record_creation!
      record = yield
      _data.merge_raw!(record._data)
      record
    end

    def options_for_creation(options)
      return options if params_from_link.blank?
      options = {} if options.blank?
      options.deep_merge(params: params_from_link)
    end
  end
end
