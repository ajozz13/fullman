#!/usr/bin/env ruby

require "net/http"
require "net/https"
require "uri"
require 'json'
require 'ostruct'

$debug

class HTTPSender
  attr_accessor :url, :method, :content, :headers #hash of headers

  def initialize dbg=false
    $debug = dbg
  end

  def set_proxy proxy_address
    ENV[ 'http_proxy' ] = proxy_address
  end

  def execute
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
      puts "set headers....."
      @headers.each do |k, v|
        request.add_field(k, v)
      end
      request.body = @content.to_s  #must be sent as string.

      if $debug
        puts "request and body"
        puts http.inspect
        puts request.to_hash
        puts request.body
      end
      puts "Connecting to...#{ uri.request_uri }..."
      response = http.request( request )
      puts "Done.\n#{ response.inspect }"  if $debug
      puts "The service responded: ( #{ response.code } - #{ response.message } )"

      if $debug
        puts
        puts "Headers Received:"
        #puts "#{ response.to_hash.inspect }"
        response.each_header do |key, value|
                puts "#{ key }: #{ value }"
        end
        puts "-----------------------------"
      end

      puts
      puts "CL: #{ response[ "content-length" ] }" if $debug
      puts "----BODY----"
      puts response.body
      puts "------------"

      resp = JSON.parse(response.body, object_class: OpenStruct)
      #code = resp["code"].to_i
      code = resp.code.to_i
      puts code
      #puts resp["message"]
      puts resp.message

    rescue Exception => exception
      STDERR.write "Exception: #{ exception }\n"
      puts exception.backtrace
      raise exception
    ensure

    end

  end

end
