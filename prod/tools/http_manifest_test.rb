#!/usr/bin/env ruby

require 'pathname'
require_relative 'http_send'
require_relative '../../prod/def/ibc_aams.rb'
include IBC::AAMS

e_code = 0
begin
        #Send a file test example to IBC Test manifest API
        #Documentation: https://api.pactrak.com/transactions/manifest_documentation.html

        raise "USAGE: #{__FILE__} Path_to_test_file your_email" unless ARGV.length == 2
        file = ARGV[ 0 ]
        raise "The test file does not exist! - #{ file }" unless File.exists?( file ) && File.file?( file )

        email = ARGV[ 1 ]
        raise "The parameter for email may not be a proper email address #{ email }" unless email =~ URI::MailTo::EMAIL_REGEXP

        puts "AAMS Test File: #{ file } - processed under address: #{ email }"

        sender = HTTPSender.new #true
        sender.url = "https://api.pactrak.com/tests/manifest"
        sender.method = "POST"
        sender.headers = { "Content-Type" => "application/json" }
        sender.content = IBC::AAMS.setup_manifest_object( file, email )

        sender.execute

        puts "#{ sender.response_json.response_message }"

rescue Exception => exception
  STDERR.write "Exception: #{ exception }\n"
  puts exception.backtrace
  e_code = 1
ensure
  exit e_code
end
