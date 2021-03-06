require 'fileutils'
require 'digest'
require 'json'
require 'openssl'
require 'zip'
require 'base64'

class PushPackageGenerator
  def initialize(user_id)
    self.user_id = user_id
    self.temp_dir = File.join Rails.root, "tmp", "#{user_id}_#{Time.now.to_i}", "webapp.pushpackage"
  end

  def generate
    copy_files_to_temp
    checksum_files
    sign_files
    file = zip_files
    clean
    file
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
      file.write JSON.generate(checksums).gsub('/','\\/')
    end
  end

  def sign_files
    Rails.logger.debug "signing the the manifest"
    data = File.read(File.join(temp_dir, 'manifest.json'))
    crt_file = File.join(Rails.root, "config", "push_certificate.p12")
    crt = OpenSSL::PKCS12.new File.read(crt_file)
    key = ""
    signature = OpenSSL::PKCS7::sign(crt.certificate, crt.key, data, [], OpenSSL::PKCS7::DETACHED)
    signature = signature.to_s.split("\n")
    signature = signature[1..signature.length-2].join("\n")
    Rails.logger.debug signature.to_s
    File.open(File.join(temp_dir, "signature"), "wb") { |file| file.write Base64.decode64 signature.to_s }
  end

  def zip_files
    Rails.logger.debug "generating the zip"
    zipfile_name = "#{Rails.root}/tmp/#{user_id}_pushpackage.zip"
    FileUtils.rm_f zipfile_name
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      Dir.glob("#{temp_dir}/**/*").each do |file|
        title = Pathname.new(file).relative_path_from(Pathname.new(temp_dir))
        Rails.logger.debug "archiving #{title}"
        zipfile.add(title, file)
      end

    end
    zipfile_name
  end

  def clean
    Rails.logger.debug "cleaning"
    FileUtils.rm_rf temp_dir
  end
end