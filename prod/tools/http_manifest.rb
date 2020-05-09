require 'pathname'
require_relative 'http_send'
require_relative '../../prod/def/ibc_aams.rb'
include IBC::AAMS


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

        sender = HTTPSender.new true
        sender.url = "https://api.pactrak.com/manifests/upload"
        sender.method = "POST"
        sender.execute file

        puts "#{ sender.response_json.response_message }"


rescue Exception => exception
  STDERR.write "Exception: #{ exception }\n"
  puts exception.backtrace
  e_code = 1
ensure
  exit e_code
end
