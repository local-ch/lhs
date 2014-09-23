class ServerError < LHS::Error
end

class InternalServerError < ServerError
end

class NotImplemented < ServerError
end

class BadGateway < ServerError
end

class ServiceUnavailable < ServerError
end

class GatewayTimeout < ServerError
end

class HttpVersionNotSupported < ServerError
end

class InsufficientStorage < ServerError
end

class NotExtended < ServerError
end
