require 'rubygems'
require 'chef'
require 'chef/handler'
require 'net/https'
require 'uri'

class ChefGroveIOHandler < Chef::Handler
  VERSION = '0.0.1'

  def initialize(url_hash)
    @url = "https://grove.io/api/notice/#{url_hash}/"
    @timestamp = Time.now.getutc
  end

  def report

    # build the message
    status = failed? ? "failed" : "succeeded"
    message = "Chef run on #{node} has #{status}."

    # notify stdout and via log.error if we have a terminal
    unless STDOUT.tty?
      begin
        timeout(10) do
          uri = URI.parse @url
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          request = Net::HTTP::Post.new(uri.request_uri)
          request.set_form_data({"service" => "ChefReport", "message" => message})

          response = http.request(request)
          Chef::Log.info("Notified chefs via grove.io")
        end
      rescue Timeout::Error
        Chef::Log.error("Timed out while attempting to message chefs via grove.io")
      end
    end
  end

end
