require 'active_support'

class LHS::Proxy

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
      raise(ArgumentError, 'Record already exists') if _raw.keys != [:href] && item?

      record = yield
      merge_record_data(record)
      # Needed to handle unexpanded collection which looks the same as item
      reload!
      record
    end

    def options_for_creation(options)
      return options if params_from_link.blank?
      options = {} if options.blank?
      options.deep_merge(params: params_from_link)
    end

    def merge_record_data(record)
      if collection?
        _collection << record._raw
      elsif item?
        _data.merge_raw!(record._data)
      end
    end
  end
end
