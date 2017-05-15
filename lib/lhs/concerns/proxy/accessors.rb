require 'active_support'

class LHS::Proxy
  module Accessors
    extend ActiveSupport::Concern

    # Keywords that would not be forwarded via method missing
    # FIXME: Extend the set of keywords
    BLACKLISTED_KEYWORDS = %w(new proxy_association)

    private

    def set(name, value)
      key = name.to_s.gsub(/=$/, '')
      _data._raw[key.to_sym] = value
    end

    def get(name, *args)
      name = args.first if name == :[]
      value = _data._raw[name.to_s]
      if value.nil? && _data._raw.present?
        value = _data._raw[name.to_sym]
        value = _data._raw[name.to_s.classify.to_sym] if value.nil?
      end

      record = LHS::Record.for_url(value[:href]) if value.is_a?(Hash) && value[:href]

      access_item(value, record) ||
        access_collection(value, record) ||
        convert(value)
    end

    def accessing_item?(value, record)
      return false unless value.is_a?(Hash)
      return false if record && value[record.items_key].present?
      return false if !record && value[LHS::Record::Configuration::DEFAULT_ITEMS_KEY].present?
      true
    end

    def accessing_collection?(value, record)
      return true if value.is_a?(Array)
      return true if value.is_a?(Hash) && record && value[record.items_key].present?
      return true if value.is_a?(Hash) && !record && value[LHS::Record::Configuration::DEFAULT_ITEMS_KEY].present?
    end

    def convert(value)
      return value unless value.is_a?(String)
      if date_time?(value)
        Time.zone.parse(value)
      elsif date?(value)
        Date.parse(value)
      else
        value
      end
    end

    def access_item(value, record)
      return unless accessing_item?(value, record)
      wrap_return(value, record)
    end

    def access_collection(value, record)
      return unless accessing_collection?(value, record)
      collection_data = LHS::Data.new(value, _data)
      collection = LHS::Collection.new(collection_data)
      wrap_return(collection, record)
    end

    def wrap_return(value, record)
      data = LHS::Data.new(value, _data)
      return record.new(data) if record
      data
    end

    def date?(value)
      value[date_time_regex, :date].presence
    end

    def time?(value)
      value[date_time_regex, :time].presence
    end

    def date_time?(value)
      date?(value) && time?(value)
    end

    def date_time_regex
      /(?<date>\d{4}-\d{2}-\d{2})?(?<time>T\d{2}:\d{2}(:\d{2}(\.\d*.\d{2}:\d{2})*)?)?/
    end
  end
end
