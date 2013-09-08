class LoggerController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    message = JSON.parse request.body.read
    Rails.logger.debug "error from safari push notification\n #{JSON.pretty_generate message}"
  end
end
