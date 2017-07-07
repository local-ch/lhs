require 'lhc'

module LHS
  autoload :Configuration,
    'lhs/concerns/configuration'
  autoload :AutoloadRecords,
    'lhs/concerns/autoload_records'
  autoload :Collection,
    'lhs/collection'
  autoload :Complex,
    'lhs/complex'
  autoload :Config,
    'lhs/config'
  autoload :Data,
    'lhs/data'
  autoload :Endpoint,
    'lhs/endpoint'
  autoload :Errors,
    'lhs/errors/base'
  module Errors
    autoload :Nested,
      'lhs/errors/nested'
  end
  autoload :Inspect,
    'lhs/concerns/inspect'
  autoload :Item,
    'lhs/item'
  autoload :Pagination,
    'lhs/pagination/base'
  module Pagination
    autoload :Offset,
      'lhs/pagination/offset'
    autoload :Page,
      'lhs/pagination/page'
    autoload :Start,
      'lhs/pagination/start'
  end
  autoload :Proxy,
    'lhs/proxy'
  autoload :Record,
    'lhs/record'

  include Configuration
  include AutoloadRecords if defined?(Rails)

  require 'lhs/record' # as lhs records in an application are directly inheriting it

  require 'lhs/railtie' if defined?(Rails)
end
