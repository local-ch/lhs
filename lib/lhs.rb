# frozen_string_literal: true

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
  autoload :ExtendedRollbar,
    'lhs/interceptors/extended_rollbar/interceptor'
  autoload :Endpoint,
    'lhs/endpoint'
  autoload :Inspect,
    'lhs/concerns/inspect'
  module Interceptors
    module AutoOauth
      autoload :ThreadRegistry,
        'lhs/interceptors/auto_oauth/thread_registry'
      autoload :Interceptor,
        'lhs/interceptors/auto_oauth/interceptor'
    end
    module RequestCycleCache
      autoload :ThreadRegistry,
        'lhs/interceptors/request_cycle_cache/thread_registry'
      autoload :Interceptor,
        'lhs/interceptors/request_cycle_cache/interceptor'
    end
    module ExtendedRollbar
      autoload :ThreadRegistry,
        'lhs/interceptors/extended_rollbar/thread_registry'
      autoload :Interceptor,
        'lhs/interceptors/extended_rollbar/interceptor'
      autoload :Handler,
        'lhs/interceptors/extended_rollbar/handler'
    end
  end
  autoload :IsHref,
    'lhs/concerns/is_href'
  autoload :Item,
    'lhs/item'
  autoload :OAuth,
    'lhs/concerns/o_auth.rb'
  autoload :OptionBlocks,
    'lhs/concerns/option_blocks'
  autoload :Pagination,
    'lhs/pagination/base'
  module Pagination
    autoload :Offset,
      'lhs/pagination/offset'
    autoload :Page,
      'lhs/pagination/page'
    autoload :Start,
      'lhs/pagination/start'
    autoload :Link,
      'lhs/pagination/link'
  end
  autoload :Problems,
    'lhs/problems/base'
  module Problems
    autoload :Base,
      'lhs/problems/base'
    autoload :Errors,
      'lhs/problems/errors'
    autoload :Nested,
      'lhs/problems/nested/base'
    module Nested
      autoload :Base,
      'lhs/problems/nested/base'
      autoload :Errors,
      'lhs/problems/nested/errors'
      autoload :Warnings,
      'lhs/problems/nested/warnings'
    end
    autoload :Warnings,
      'lhs/problems/warnings'
  end
  autoload :Proxy,
    'lhs/proxy'
  autoload :Record,
    'lhs/record'
  autoload :Unprocessable,
    'lhs/unprocessable'

  include Configuration
  include AutoloadRecords if defined?(Rails)
  include OptionBlocks

  require 'lhs/record' # as lhs records in an application are directly inheriting it

  require 'lhs/railtie' if defined?(Rails)
end
