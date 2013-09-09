class PushNotificationSender
  def initialize(device_token = 'CC3C1E4E3DAC5581596EA95373BE4242F4B42F635759B187305B9B4A6CEEF446')
    configure_connection
    self.device_token = device_token
  end

  # def send
  #   notification = APNS::Notification.new(device_token, :alert => alert)
  #   APNS.send_notifications([notification])
  # end

  # private

  attr_accessor :device_token

  def configure_connection
    APNS.pem  = pem
    APNS.host = host
  end

  def alert
    {
      "title" => "New comment",
      "body" => "This person has posted a comment to the article",
      "action" => "View"
    }
  end

  def url_args
    ["1"]
  end

  def payload
    {
      "aps" => {
        "alert" => alert,
        "url-args" => url_args
      }
    }.to_json
  end

  def payload_size
    payload.size
  end

  def host
    'gateway.push.apple.com'
  end

  def pem
    File.join Rails.root, 'config', 'client-cert.pem'
  end

  def port
    2195
  end

  def expiry
    86400
  end

  def to_binary(options = {})
    id_for_pack = 0
    [1, id_for_pack, expiry, 0, 32, device_token, payload_size, payload].pack("cNNccH*na*")
  end

  def open_connection
    pass = ''

    context      = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(File.read(pem))
    context.key  = OpenSSL::PKey::RSA.new(File.read(pem), pass)

    puts "opening connection to #{host}:#{port}"
    sock         = TCPSocket.new(host, port)
    ssl          = OpenSSL::SSL::SSLSocket.new(sock,context)
    ssl.connect

    return sock, ssl
  end

  def send
    sock, ssl = open_connection

    ssl.write(to_binary)

    ssl.close
    sock.close
  end
end