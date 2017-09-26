require 'active_support'

class LHS::Proxy

  module Problems
    extend ActiveSupport::Concern

    included do
      attr_writer :errors, :warnings
    end

    def initialize(data)
      super(data)
    end

    def errors
      @errors ||= LHS::Problems::Errors.new(nil, record)
    end

    def warnings
      @warnings ||= LHS::Problems::Warnings.new(_raw, record)
    end
  end
end
