require 'pry'
require 'webmock/rspec'

describe 'Require LHS' do
  context 'request without rails' do
    it 'does have deep_merge dependency met' do
      expect { require 'lhs' }.not_to raise_error
    end
  end
end
