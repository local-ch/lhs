# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include LHS::OAuth

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def root
    render nothing: true
  end

  def access_token
    params[:access_token]
  end
end
