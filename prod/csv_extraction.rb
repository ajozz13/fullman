#!/usr/bin/env jruby

require 'yaml'
require 'csv'
require_relative "../fullman.rb"
require_relative 'tools/email.rb'
require_relative 'tools/http_send.rb'
require_relative 'def/ibc_aams.rb'
include IBC::AAMS

$debug
$output

def create_output_line input_array
  sl = ""
  input_array.each do |s|
    sl = "#{ sl }#{ s }"
    sl = "#{ sl }\n" unless sl[-1] == "\n"
  end
  return sl
end

def set_items object, conf, data
  ##Set defaults
  keys = conf.keys
  if keys.include? "defaults"
    puts "set defaults" if $debug
    keys = conf[ "defaults" ].keys
    keys.each do |key|
      #puts "#{ key } : #{conf[ "defaults" ][ key ]}"
      object.send "#{ key }=", conf[ "defaults" ][ key ]
    end
    keys = conf.keys.reject{ |k| k == "defaults" }
  end

  #set the rest of the keys...
  puts "Set: #{keys}" if $debug
  keys.each do |key|
    object.send "#{ key }=", data[ conf[ key ] ]
  end
  puts "Created: #{object}" if $debug

end

exit_code = 0

if ARGV[0] == "-h"
  puts "Usage: #{__FILE__} input.yaml [ -d -e|-s ]"
  puts "  -d 'print debug information.'"
  puts "  -e 'produce the output and send via email.'"
  puts "  -s 'produce the output and send via http post.'"
  puts "If no arguments are given the output will be standard out."
  exit exit_code
end

begin
  $debug = ARGV.include? "-d"
  $email_submit = ARGV.include? "-e"
  $http_submit = ARGV.include? "-s"

  file = ARGV[0]

  raise "Plese specify an input file.  Usage: #{__FILE__} input.yaml" if file.nil?

  props = YAML.load(File.open( file ))

  puts props.inspect if $debug
  #cons_conf = props[ "consignee" ]
  #shpr_conf = props[ "shipper" ]
  #ship_conf = props[ "shipment" ]

  puts "CSV input file Path: #{ props['file'] }" if $debug

  file = CSV.open( props['file'] , { :headers => props['headers'] } )
  $output = Array.new
  $shipment_lines = Array.new

  if props.include? "emails"
    emails = props[ "emails" ]
    notices = Notices.new
    notices.success = emails[ 'success' ]
    notices.failure = emails[ 'failure' ]
    $output.push notices
  end

  manifest = Manifest.new
  file.each_with_index do |row, i|
    puts "Process: #{ row[ 0 ] }" if $debug

    #process manifest line if available.
    if ( i == 0 ) && ( props.include? "manifest" )
      set_items manifest, props[ "manifest" ], row
      $output.push manifest
    end

    #Build shipper
    shipr = Customer.new true  ## ENSURE shipper is created with a boolean.
    set_items shipr, props[ "shipper" ], row

    #Build consignee
    cons = Customer.new
    set_items cons, props[ "consignee" ], row

    #Build shipment
    shipmt = Shipment.new
    set_items shipmt, props[ "shipment" ], row
    $shipment_lines.push ShipmentLine.new shipr, cons, shipmt
  end

  msg = create_output_line $output
  sl = create_output_line $shipment_lines

  #finally handle the output
  if $email_submit
    raise "Email destination is not defined " if emails[ 'aams' ].nil?
    email = StandardEmail.new
    email.from = 'nobody+aams_manifest@ibcinc.com'
    email.to = emails[ 'aams' ]
    email.subject = 'IBC Manifest'
    email.message = msg
    email.send_message

  elsif $http_submit

    ibc_aams = IBC::AAMS.to_manifest_hash( emails[ 'aams' ], notices.to_single_string, manifest.to_s, sl )
    sender = HTTPSender.new true  #with debug mode on
    sender.url = "https://api.pactrak.com/manifest/aams?_test"
    sender.method = "POST"
    sender.headers = { "Content-Type" => "application/json" }
    sender.content = ibc_aams
    sender.execute

  else # output to standard output
    puts "#{ msg }#{ sl }"
  end

rescue Exception => e
        puts "Exception: #{e}"
        e.backtrace
        exit_code = 2
ensure
  exit exit_code
end
