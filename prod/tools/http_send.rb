#!/usr/bin/env ruby

require "net/http"
require "net/https"
require 'multipart_body'
require "uri"
require 'json'
require 'ostruct'

$debug

class HTTPSender
  attr_accessor :url, :method, :content, :headers #hash of headers
  attr_reader  :response, :response_code, :response_message, :response_json

  def initialize dbg=false
    $debug = dbg
  end

  def set_proxy proxy_address
    ENV[ 'http_proxy' ] = proxy_address
  end

  def setup_file_body file
          file_part = ""
          File.open( file, 'rb' ) do |f|
                  file_part = Part.new :name => 'File', :body => f,
                       :filename => file,
                       :content_type => 'text/plain'
          end
          boundary = "---------------------------#{rand(10000000000000000000)}"
          body =  MultipartBody.new [file_part], boundary
          @headers = { "Content-Type" => "multipart/form-data; boundary=#{boundary}" }
          body.to_s
  end

  def execute file_path=nil
    file_upload = !file_path.nil?
    begin
      uri = URI.parse @url
      print "Set up Connection....." if $debug
      http = Net::HTTP.new( uri.host, uri.port )
      http.use_ssl = uri.scheme.eql? "https"
      puts "Use SSL? #{ http.use_ssl? }" if $debug
      request = case @method
        when "GET"
          puts "GET Method"
          Net::HTTP::Get.new( uri.request_uri )
        when "POST"
          puts "POST Method...."
          Net::HTTP::Post.new( uri.request_uri )
        when "PUT"
          puts "PUT Method...."
          Net::HTTP::Put.new( uri.request_uri )
        when "DELETE"
          puts "DELETE Method...."
          Net::HTTP::Delete.new( uri.request_uri )
      end

      request.body = file_upload ? setup_file_body( file_path ) : @content.to_s

      puts "set headers....."
      if @headers
              @headers.each do |k, v|
                      request.add_field(k, v)
              end
      end

      if $debug
        puts "request and body"
        puts http.inspect
        puts request.to_hash
        puts request.body
      end
      puts "Connecting to...#{ uri.request_uri }..."
      @response = http.request( request )
      puts "Done.\n#{ @response.inspect }"  if $debug
      @response_code = @response.code.to_i
      @response_message = @response.message
      puts "The service responded: ( #{ @response_code } - #{ @response_message } )"

      if $debug
        puts
        puts "Headers Received:"
        #puts "#{ response.to_hash.inspect }"
        @response.each_header do |key, value|
                puts "#{ key }: #{ value }"
        end
        puts "-----------------------------"
      end

      if $debug
              puts "CL: #{ @response[ "content-length" ] }"
              puts "----BODY----"
              puts @response.body
              puts "------------"
      end

      @response_json = JSON.parse( @response.body, object_class: OpenStruct )
      #code = resp["code"].to_i
      #code = resp.code.to_i
      #puts @response_code.to_i
      #puts resp["message"]
      #puts @response_message

    rescue Exception => exception
      STDERR.write "Exception: #{ exception }\n"
      puts exception.backtrace
      raise exception
    ensure

    end

  end

end
