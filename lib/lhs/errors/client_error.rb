class ClientError < LHS::Error
end

class BadRequest < ClientError
end

class Unauthorized < ClientError
end

class PaymentRequired < ClientError
end

class Forbidden < ClientError
end

class Forbidden < ClientError
end

class NotFound < ClientError
end

class MethodNotAllowed < ClientError
end

class NotAcceptable < ClientError
end

class ProxyAuthenticationRequired < ClientError
end

class RequestTimeout < ClientError
end

class Conflict < ClientError
end

class Gone < ClientError
end

class LengthRequired < ClientError
end

class PreconditionFailed < ClientError
end

class RequestEntityTooLarge < ClientError
end

class RequestUriToLong < ClientError
end

class UnsupportedMediaType < ClientError
end

class RequestedRangeNotSatisfiable < ClientError
end

class ExpectationFailed < ClientError
end

class UnprocessableEntity < ClientError
end

class Locked < ClientError
end

class FailedDependency < ClientError
end

class UpgradeRequired < ClientError
end
