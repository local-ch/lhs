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

      return access_item(value) if value.is_a?(Hash)
      return access_collection(value) if value.is_a?(Array)
      convert(value)
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

    def access_item(value)
      record = LHS::Record.for_url(value[:href]) if value[:href]
      data = LHS::Data.new(value, _data)
      if record
        record.new(data)
      else
        data
      end
    end

    def access_collection(value)
      data = LHS::Data.new(value, _data)
      collection = LHS::Collection.new(data)
      LHS::Data.new(collection, _data)
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
      /(?<date>\d{4}-\d{2}-\d{2})?(?<time>T\d{2}:\d{2}:\d{2}(\.\d*.\d{2}:\d{2})*)?/
    end
  end
end
