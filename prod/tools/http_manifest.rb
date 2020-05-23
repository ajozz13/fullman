require 'pathname'
require_relative 'http_send'
require "net/http"
require "net/https"
require 'multipart_body'
require_relative '../../prod/def/ibc_aams.rb'
include IBC::AAMS


def send_http file, url

        file_part = ""
        File.open(file, 'rb') do |f|
                file_part = Part.new :name => 'File', :body => f,
                     :filename => file,
                     :content_type => 'text/plain'
        end

        boundary = "---------------------------#{ rand(10000000000000000000) }"
        body =  MultipartBody.new [file_part], boundary

        uri = URI.parse url
        http = Net::HTTP.new( uri.host, uri.port )
        http.use_ssl = uri.scheme.eql? "https"
        request = Net::HTTP::Post.new( uri.request_uri )

        request.body = body.to_s
        request.add_field( "Content-Type", "multipart/form-data; boundary=#{boundary}" )
        response = http.request( request )

        puts
        puts "#{ response.inspect }"
        puts "#{ response.body }"
end

e_code = 0
begin
        #Send a manifest example to IBC manifest API  **Note this is a production service
        #Only use to send real live manifests
        #Documentation: https://api.pactrak.com/manifests/manifest.html
        #Your file name should use the email prefix of your production email accounts
        #If you transmit to: aams-data-mycompany-cfs@pactrak.com
        #The file name should be: aams-data-mycompany-cfs.txt   --It can also be .csv

        raise "USAGE: #{__FILE__} Path_to_manifest_file" unless ARGV.length == 1
        file = ARGV[ 0 ]

        puts "AAMS Test File: #{ file }"

# send the file using this function.

        url = "https://api.pactrak.com/manifests/upload"

        send_http file, url

# or you can also use the IBC sender class and parse the JSON if you need
=begin
        sender = HTTPSender.new
        sender.url = url
        sender.method = "POST"
        sender.execute file

        puts "#{ sender.response_json.response_message }"
=end

rescue Exception => exception
  STDERR.write "Exception: #{ exception }\n"
  puts exception.backtrace
  e_code = 1
ensure
  exit e_code
end
