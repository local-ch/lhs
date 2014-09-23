require 'rails_helper'

describe LHS::Error do

  context 'find' do

    it 'finds error class by status code' do
      expect(LHS::Error.find('400')).to eq BadRequest
      expect(LHS::Error.find('401')).to eq Unauthorized
      expect(LHS::Error.find('402')).to eq PaymentRequired
      expect(LHS::Error.find('403')).to eq Forbidden
      expect(LHS::Error.find('403')).to eq Forbidden
      expect(LHS::Error.find('404')).to eq NotFound
      expect(LHS::Error.find('405')).to eq MethodNotAllowed
      expect(LHS::Error.find('406')).to eq NotAcceptable
      expect(LHS::Error.find('407')).to eq ProxyAuthenticationRequired
      expect(LHS::Error.find('408')).to eq RequestTimeout
      expect(LHS::Error.find('409')).to eq Conflict
      expect(LHS::Error.find('410')).to eq Gone
      expect(LHS::Error.find('411')).to eq LengthRequired
      expect(LHS::Error.find('412')).to eq PreconditionFailed
      expect(LHS::Error.find('413')).to eq RequestEntityTooLarge
      expect(LHS::Error.find('414')).to eq RequestUriToLong
      expect(LHS::Error.find('415')).to eq UnsupportedMediaType
      expect(LHS::Error.find('416')).to eq RequestedRangeNotSatisfiable
      expect(LHS::Error.find('417')).to eq ExpectationFailed
      expect(LHS::Error.find('422')).to eq UnprocessableEntity
      expect(LHS::Error.find('423')).to eq Locked
      expect(LHS::Error.find('424')).to eq FailedDependency
      expect(LHS::Error.find('426')).to eq UpgradeRequired
      expect(LHS::Error.find('500')).to eq InternalServerError
      expect(LHS::Error.find('501')).to eq NotImplemented
      expect(LHS::Error.find('502')).to eq BadGateway
      expect(LHS::Error.find('503')).to eq ServiceUnavailable
      expect(LHS::Error.find('504')).to eq GatewayTimeout
      expect(LHS::Error.find('505')).to eq HttpVersionNotSupported
      expect(LHS::Error.find('507')).to eq InsufficientStorage
      expect(LHS::Error.find('510')).to eq NotExtended
    end

    it 'finds error class also by exteded status code' do
      expect(LHS::Error.find('40001')).to eq BadRequest
      expect(LHS::Error.find('50002')).to eq InternalServerError
    end

    it 'returns UnknownError if not specific error was found' do
      expect(LHS::Error.find('0')).to eq UnknownError
      expect(LHS::Error.find('')).to eq UnknownError
      expect(LHS::Error.find('600')).to eq UnknownError
    end
  end
end
