require 'rails_helper'

describe LHS::Request do

  context 'error handling' do

    def to_fail_with(error)
      raise_error(error)
    end

    def expect_status_code(status_code)
      stub_request(:get, "http://something/#{status_code}").to_return(status: status_code)
      expect(
        -> { LHS::Request.new(url: "http://something/#{status_code}") }
      ).to yield
    end

    it 'raises errors for anything but 2XX response codes' do
      expect_status_code(400) { to_fail_with(BadRequest) }
      expect_status_code(401) { to_fail_with(Unauthorized) }
      expect_status_code(402) { to_fail_with(PaymentRequired) }
      expect_status_code(403) { to_fail_with(Forbidden) }
      expect_status_code(403) { to_fail_with(Forbidden) }
      expect_status_code(404) { to_fail_with(NotFound) }
      expect_status_code(405) { to_fail_with(MethodNotAllowed) }
      expect_status_code(406) { to_fail_with(NotAcceptable) }
      expect_status_code(407) { to_fail_with(ProxyAuthenticationRequired) }
      expect_status_code(408) { to_fail_with(RequestTimeout) }
      expect_status_code(409) { to_fail_with(Conflict) }
      expect_status_code(410) { to_fail_with(Gone) }
      expect_status_code(411) { to_fail_with(LengthRequired) }
      expect_status_code(412) { to_fail_with(PreconditionFailed) }
      expect_status_code(413) { to_fail_with(RequestEntityTooLarge) }
      expect_status_code(414) { to_fail_with(RequestUriToLong) }
      expect_status_code(415) { to_fail_with(UnsupportedMediaType) }
      expect_status_code(416) { to_fail_with(RequestedRangeNotSatisfiable) }
      expect_status_code(417) { to_fail_with(ExpectationFailed) }
      expect_status_code(422) { to_fail_with(UnprocessableEntity) }
      expect_status_code(423) { to_fail_with(Locked) }
      expect_status_code(424) { to_fail_with(FailedDependency) }
      expect_status_code(426) { to_fail_with(UpgradeRequired) }
      expect_status_code(500) { to_fail_with(InternalServerError) }
      expect_status_code(501) { to_fail_with(NotImplemented) }
      expect_status_code(502) { to_fail_with(BadGateway) }
      expect_status_code(503) { to_fail_with(ServiceUnavailable) }
      expect_status_code(504) { to_fail_with(GatewayTimeout) }
      expect_status_code(505) { to_fail_with(HttpVersionNotSupported) }
      expect_status_code(507) { to_fail_with(InsufficientStorage) }
      expect_status_code(510) { to_fail_with(NotExtended) }
    end
  end
end
