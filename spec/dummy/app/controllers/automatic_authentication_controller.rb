# frozen_string_literal: true

class AutomaticAuthenticationController < ApplicationController

  def o_auth
    render json: {
      record: DummyRecordWithOauth.find(1),
      records: DummyRecordWithOauth.where(color: blue)
    }
  end
end
