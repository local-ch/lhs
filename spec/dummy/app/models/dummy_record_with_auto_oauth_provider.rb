class DummyRecordWithAutoOauthProvider < Providers::InternalServices
  endpoint 'http://internalservice/v2/records'
  endpoint 'http://internalservice/v2/records/{id}'
end
