class LHS::Error < StandardError

  attr_accessor :response

  def self.map
    {
      400 => BadRequest,
      401 => Unauthorized,
      402 => PaymentRequired,
      403 => Forbidden,
      403 => Forbidden,
      404 => NotFound,
      405 => MethodNotAllowed,
      406 => NotAcceptable,
      407 => ProxyAuthenticationRequired,
      408 => RequestTimeout,
      409 => Conflict,
      410 => Gone,
      411 => LengthRequired,
      412 => PreconditionFailed,
      413 => RequestEntityTooLarge,
      414 => RequestUriToLong,
      415 => UnsupportedMediaType,
      416 => RequestedRangeNotSatisfiable,
      417 => ExpectationFailed,
      422 => UnprocessableEntity,
      423 => Locked,
      424 => FailedDependency,
      426 => UpgradeRequired,

      500 => InternalServerError,
      501 => NotImplemented,
      502 => BadGateway,
      503 => ServiceUnavailable,
      504 => GatewayTimeout,
      505 => HttpVersionNotSupported,
      507 => InsufficientStorage,
      510 => NotExtended
    }
  end

  def self.find(status_code)
    status_code = status_code.to_s[0..2].to_i
    error = map[status_code]
    error ||= UnknownError
    error
  end

  def initialize(message, response = nil)
    super(message)
    self.response = response
  end

end
