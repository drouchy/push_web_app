require 'fileutils'

class PushPackageController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    Rails.logger.info "generating new package controller"
    file = PushPackageGenerator.new("1").generate
    Rails.logger.info "File generated: #{file}"
    send_file file
  end
end