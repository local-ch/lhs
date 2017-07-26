require 'active_support'

module LHS

  module ItemsHandler
    extend ActiveSupport::Concern

    def access_items(input:, record: nil)
      items_key = access_items_key(record)
      input.dig(*items_key)
    end

    # Sets the items value unless it's set already (initializes)
    def initialize_items(input:, value: nil, record: nil)
      items_key = access_items_key(record)
      input[items_key] = value
    end

    def concat_items(input:, items:, record: nil)
      items_key = access_items_key(record)
      input.dig(*items_key).concat(items)
    end

    private

    def access_items_key(record)
      record && record.items_key || LHS::Record.items_key
    end
  end
end
