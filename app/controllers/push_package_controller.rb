require 'fileutils'

class PushPackageController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    Rails.logger.info "generating new package controller"
    file = PushPackageGenerator.new("1").generate
    Rails.logger.info "File generated: #{file}"
    send_file file
  end

  def register
    Rails.logger.info "registring the push notification"
    Rails.logger.info request.headers['Authorization']
    user = User.first
    user.device_token = params[:device_id]
    user.save!
    render nothing: true
  end
end