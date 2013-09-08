require 'fileutils'
require 'digest'
require 'json'

class PushPackageGenerator
  def initialize(user_id)
    self.user_id = user_id
    self.temp_dir = File.join Rails.root, "tmp", "#{user_id}_#{Time.now.to_i}", "webapp.pushpackage"
  end

  def generate
    copy_files_to_temp
    checksum_files
    sign_files
    zip_files
    clean
  end

  private

  attr_accessor :user_id, :temp_dir

  def copy_files_to_temp
    Rails.logger.debug "copy files to temp"
    FileUtils.mkdir_p temp_dir
    FileUtils.copy_entry File.join(Rails.root, "webapp.pushpackage"), temp_dir
  end

  def checksum_files
    Rails.logger.debug "generating the manifest"
    checksums = Dir.glob("#{temp_dir}/**/*").inject({}) do |digests, file|
      if File.file? file
        checksum = Digest::SHA1.hexdigest File.read(file)
        pathname = Pathname.new(file).relative_path_from(Pathname.new(temp_dir))
        Rails.logger.debug "checksums of #{pathname} - #{checksum}"
        digests.update pathname => checksum
      end
      digests
    end

    File.open(File.join(temp_dir, "manifest.json"), "w") do |file|
      file.write JSON.pretty_generate checksums
    end
  end

  def sign_files
    Rails.logger.debug "signing the the manifest"
  end

  def zip_files
    Rails.logger.debug "generating the zip"
  end

  def clean
    Rails.logger.debug "cleaning"
    # FileUtils.rm_rf temp_dir
  end
end