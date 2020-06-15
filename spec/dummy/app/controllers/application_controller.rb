# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include LHS::OAuth
  ACCESS_TOKEN = 'token-12345'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def root
    render nothing: true
  end

  def access_token
    ACCESS_TOKEN
  end

  def access_token_provider_1
    "#{ACCESS_TOKEN}_provider_1"
  end

  def access_token_provider_2
    "#{ACCESS_TOKEN}_provider_2"
  end
end
