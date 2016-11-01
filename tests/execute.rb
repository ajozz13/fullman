#!/usr/bin/env jruby
=begin
  This is an execution test for fullman.rb
=end
require_relative "../fullman.rb"

begin
  shipper = Customer.new true
  shipper.name = "Abner Serrano"
  shipper.address1 = "8401 NW 17th St"
  shipper.city = "Miami"
  shipper.state = "FL"
  shipper.zip = "33126"
  shipper.country = "US"
  shipper.phone = "305-591-8080"
  shipper.account = "8040"

  cust = Customer.new
  cust.name = "Alberto"
  cust.company = "IBC"
  cust.address1 = "11565 Western Drive"
  cust.address2 = "Apt B16"
  cust.city = "Ft Lauderdale"
  cust.state = "FL"
  cust.zip = "33344"
  cust.country = "US"
  cust.phone = "786 547 1335"

  item = Shipment.new 
  item.hawb = "32323423423"
  item.vendor_reference = "604946479985656"
  item.origin = "USA"
  item.destination = "USG"
  item.service_provider = "FDX"
  item.pieces = "1"
  item.weight = "10"
  item.weight_unit = "P"
  item.contents = "APX"
  item.value = "15"
  item.description = "T shirts"
  item.terms = "P"
  item.packaging = "B"
  item.service_type = "GD"
  item.comments = "Please deliver now."

  notices = Notices.new
  notices.success = "alberto@ibcinc.com,jose.miguel@comcast.net"
  notices.failure = "me.com"

  manifest = Manifest.new
  manifest.id = "ABC123"
  manifest.date = "20161020"
  manifest.origin = "BUE"
  manifest.destination = "NYC"
  manifest.flight = "AA2030"
  manifest.master = "12345678911"

  #Produce an actual manifest output
  puts notices
  puts manifest
  line = ShipmentLine.new shipper, cust, item
  10.times do
    puts line
  end

rescue Exception => exception
  STDERR.write "Exception: #{ exception }\n"
  puts exception.backtrace
  exit 2
ensure
  #any cleanup?
end
exit 0
