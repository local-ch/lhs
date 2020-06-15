# frozen_string_literal: true

class AutomaticAuthenticationController < ApplicationController

  def o_auth
    render json: {
      record: DummyRecordWithOauth.find(1).as_json,
      records: DummyRecordWithOauth.where(color: 'blue').as_json
    }
  end
end
