module LHS::Problems
  class Errors < Base

    attr_reader :status_code, :message

    def initialize(response = nil, record = nil)
      @raw = response.body if response
      @record = record
      @messages = messages_from_response(response).with_indifferent_access
      @message = message_from_response(response)
      @status_code = response.code if response
    rescue JSON::ParserError
      @messages = (messages || {}).with_indifferent_access
      @message = 'parse error'
      add_error(@messages, 'body', 'parse error')
    end

    private

    def parse_messages(json)
      messages = {}
      fields_to_errors(json, messages) if json['fields']
      field_errors_to_errors(json, messages) if json['field_errors']
      fallback_errors(json, messages) if messages.empty?
      messages
    end

    def fallback_errors(json, messages)
      if json.present?
        json.each do |key, value|
          add_error(messages, key, value)
        end
      else
        add_error(messages, 'unknown', 'error')
      end
    end

    def field_errors_to_errors(json, messages)
      json['field_errors'].each do |field_error|
        add_error(messages, field_error['path'].join('.').to_sym, field_error['code'])
      end
    end

    def fields_to_errors(json, messages)
      json['fields'].each do |field|
        field['details'].each do |detail|
          add_error(messages, field['name'].to_sym, detail['code'])
        end
      end
    end

    def messages_from_response(response = nil)
      return {} if !response || !response.body.is_a?(String) || response.body.length.zero?
      json = JSON.parse(response.body)
      parse_messages(json)
    end

    def message_from_response(response = nil)
      return if response.blank?
      raise JSON::ParserError if response.body.blank?
      json = JSON.parse(response.body)
      json['message']
    end
  end
end
