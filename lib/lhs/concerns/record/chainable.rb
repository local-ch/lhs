# frozen_string_literal: true

require 'active_support'

class LHS::Record

  module Chainable
    extend ActiveSupport::Concern

    autoload :Chain, 'lhs/concerns/record/chainable/chain'
    autoload :Link, 'lhs/concerns/record/chainable/link'
    autoload :Parameter, 'lhs/concerns/record/chainable/link'
    autoload :Option, 'lhs/concerns/record/chainable/link'
    autoload :Pagination, 'lhs/concerns/record/chainable/link'
    autoload :Include, 'lhs/concerns/record/chainable/link'
    autoload :Reference, 'lhs/concerns/record/chainable/link'
    autoload :ErrorHandling, 'lhs/concerns/record/chainable/link'
    autoload :IgnoredError, 'lhs/concerns/record/chainable/link'
    autoload :ChainType, 'lhs/concerns/record/chainable/link'
    autoload :Resolver, 'lhs/concerns/record/chainable/resolver'

    # You can start new option chains for already fetched records (needed for save, update, valid etc.)
    def options(hash = nil)
      return method_missing(:options) if hash.nil?
      Chain.new(self.class, Option.new(hash), self)
    end

    module ClassMethods

      def where(args = nil)
        if href?(args)
          Chain.new(self, Option.new(url: args))
        else
          Chain.new(self, Parameter.new(args))
        end
      end

      def fetch
        Chain.new(self, nil).fetch
      end

      def all(hash = nil)
        chain = Chain.new(self, Parameter.new(hash))
        chain._links.push(Option.new(all: true))
        chain
      end

      def expanded(options = nil)
        Chain.new(self, Option.new(expanded: options || true))
      end

      def options(hash = nil)
        Chain.new(self, Option.new(hash))
      end

      def page(page)
        Chain.new(self, Pagination.new(page: page))
      end

      def per(limit)
        Chain.new(self, Pagination.new(per: limit))
      end

      def limit(argument = nil)
        Chain.new(self, Pagination.new(per: argument))
      end

      def rescue(error_class, handler)
        Chain.new(self, ErrorHandling.new(error_class => handler))
      end

      def ignore(*error_classes)
        chain = Chain.new(self, IgnoredError.new(error_classes.shift))
        error_classes.each do |error_class|
          chain._links.push(IgnoredError.new(error_class))
        end
        chain
      end

      def includes_first_page(*args)
        Chain.new(self, Include.new(Chain.unfold(args)))
      end

      def includes(*args)
        chain = Chain.new(self, Include.new(Chain.unfold(args)))
        chain.include_all!(args)
        chain
      end

      def references(*args)
        Chain.new(self, Reference.new(Chain.unfold(args)))
      end
    end
  end
end
