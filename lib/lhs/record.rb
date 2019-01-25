# frozen_string_literal: true

class LHS::Record
  autoload :Batch,
    'lhs/concerns/record/batch'
  autoload :Chainable,
    'lhs/concerns/record/chainable'
  autoload :Configuration,
    'lhs/concerns/record/configuration'
  autoload :Create,
    'lhs/concerns/record/create'
  autoload :CustomSetters,
    'lhs/concerns/record/custom_setters'
  autoload :Destroy,
    'lhs/concerns/record/destroy'
  autoload :Endpoints,
    'lhs/concerns/record/endpoints'
  autoload :Equality,
    'lhs/concerns/record/equality'
  autoload :Find,
    'lhs/concerns/record/find'
  autoload :FindBy,
    'lhs/concerns/record/find_by'
  autoload :First,
    'lhs/concerns/record/first'
  autoload :Last,
    'lhs/concerns/record/last'
  autoload :Mapping,
    'lhs/concerns/record/mapping'
  autoload :Model,
    'lhs/concerns/record/model'
  autoload :Pagination,
    'lhs/concerns/record/pagination'
  autoload :Request,
    'lhs/concerns/record/request'
  autoload :Relations,
    'lhs/concerns/record/relations'
  autoload :Scope,
    'lhs/concerns/record/scope'

  module RequestCycleCache
    autoload :RequestCycleThreadRegistry,
      'lhs/concerns/record/request_cycle_cache/request_cycle_thread_registry'
    autoload :Interceptor,
      'lhs/concerns/record/request_cycle_cache/interceptor'
  end

  include Batch
  include Chainable
  include Configuration
  include Create
  include CustomSetters
  include Destroy
  include Endpoints
  include Equality
  include Find
  include FindBy
  include First
  include Last
  include LHS::Inspect
  include Mapping
  include Model
  include Pagination
  include Request
  include Relations
  include RequestCycleCache
  include Scope

  delegate :_proxy, :_endpoint, :merge_raw!, :select, :becomes, :respond_to?, to: :_data

  def initialize(data = nil, apply_customer_setters = true)
    data ||= LHS::Data.new({}, nil, self.class)
    data = LHS::Data.new(data, nil, self.class) unless data.is_a?(LHS::Data)
    define_singleton_method(:_data) { data }
    apply_custom_setters! if apply_customer_setters
  end

  def as_json(options = nil)
    _data.as_json(options)
  end

  def self.build(data = nil)
    new(data)
  end

  protected

  def method_missing(name, *args, &block)
    _data.send(name, *args, &block)
  end

  def respond_to_missing?(name, include_all = false)
    _data.respond_to_missing?(name, include_all)
  end
end
