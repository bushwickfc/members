class LogsController < ApplicationController
  skip_authorization_check only: :index
  def index
    @app_log = File.read("log/#{Rails.env}.log")
  end
end
