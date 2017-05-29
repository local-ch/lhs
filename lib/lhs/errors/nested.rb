module LHS::Errors

  class Nested < Base

    def initialize(errors, scope)
      @raw = errors
      @messages = nest(errors.messages, scope)
      @message = errors.message
      @scope = scope
    end

    private

    # Filters base errors by scope
    # and reduces key by given scope name;
    # returns plain array if end of tree is reached
    def nest(messages, scope)
      messages = messages.select do |key, _|
        key.match(/^#{scope}/)
      end
      # if only one key and this key has no dots, exit with plain
      if reached_leaf?(messages)
        messages.first[1]
      else
        remove_scope(messages, scope)
      end
    end

    # Identifies if the end of nested errors tree is reached
    def reached_leaf?(messages)
      messages.keys.length == 1 &&
        !messages.first[0].match(/\./)
    end

    # Removes scope from given messages' key
    def remove_scope(messages, scope)
      messages.inject({}) do |hash, element|
        key = element[0].to_s.gsub(/^#{scope}\./, '')
        hash[key.to_sym] = element[1]
        hash
      end
    end
  end
end
