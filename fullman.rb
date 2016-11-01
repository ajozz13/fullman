=begin
  This is the class definition for IBC's Fullman Format
  The documentation is available here
  http://www.pactrak.com/manifest-to-pactrak.html
=end
require 'csv'

#Detail Shipment Records
class Customer
  attr_accessor :name, :company, :address1, :address2, :city, :state, :zip, :country, :phone, :email,
  :tax_id, :account, :reference
  attr_reader :type

  def initialize is_shipper=false
    @type = is_shipper
  end

  def strip
    self.to_s.strip
  end

  def to_s
    max = @type ? 25:35
    if @address1.length > max
      if @address2.nil?
        @address2 = @address1[ max, max*2 ]
        @address1 = @address1[ 0, max ]
      end
    end

    str = [ @name ]
    str << @company unless @type
    str << @address1 << @address2 << @city << @state << @zip << @country << @phone
    str << @email << @tax_id unless @type
    return str.to_csv
  end
end

class Shipment
  attr_accessor :vendor_reference, :origin, :destination, :service_provider, :pieces,
    :weight, :weight_unit, :contents, :currency_code, :value, :insurance, :description,
    :harmonized_code, :fda_notice, :terms, :packaging, :service_type, :comments,
    :hawb, :second_shipper_reference

  def hawb= main_trak
    main_trak = main_trak.gsub(/\D/, "")
    if main_trak.length > 11
      @hawb = main_trak[main_trak.length-11, main_trak.length]
      @second_shipper_reference = main_trak
    else
      @hawb = main_trak
    end
  end

  def to_s
    self.instance_variables.each do |name|
      val = self.instance_variable_get name
      puts "#{ name } = #{ val }" unless val.nil?
    end
  end
end

class ShipmentLine
  attr_reader :shipper, :customer, :shipment

  def initialize shpr, cons, smnt
    @shipper = shpr
    @customer = cons
    @shipment = smnt
  end

  def to_s
    #forces value to the ceil
    #We will only produce type = 12
    unless @shipment.description.nil?
      @shipment.description = "\"#{@shipment.description}\"" if @shipment.description.include? ","
    end
    str = "12,,#{ @shipment.hawb },#{ @shipper.reference },#{ @shipment.second_shipper_reference },#{ @shipment.vendor_reference }"
    str = "#{str},#{ shipment.origin },#{ @shipment.destination },,#{ @shipment.service_provider },,"
    str = "#{str},#{ @shipment.pieces },#{ @shipment.weight },#{ @shipment.weight_unit },#{ @shipment.contents }"
    str = "#{str},#{ @shipment.currency_code },#{ @shipment.value.to_f.ceil },#{ @shipment.insurance },#{ @shipment.description }"
    str = "#{str},#{ @shipment.harmonized_code },#{ @shipment.fda_notice },#{ @shipment.terms },#{ @shipment.packaging }"
    str = "#{str},#{ @shipment.service_type },,,#{ @shipper.account },,"
    str = "#{str},#{ @shipper.strip },#{ @customer.strip },#{ @shipment.comments }"
  end
end

class Notices
  attr_accessor :success, :failure

  def to_single_string
    return "#{@success},#{@failure}"
  end

  def to_s
    str = ""
    return str if @success.nil? || @failure.nil?
    @success.split( ',' ).each do |email|
      str = "#{str}6,#{email}\n"
    end
    @failure.split( ',' ).each do |email|
      str = "#{str}7,#{email}\n"
    end
    return str
  end
end

class Manifest
  attr_accessor :id, :date, :origin, :destination, :flight, :master

  def to_s
    [ 1, @id, @date, @origin, @destination, @flight, @master ].to_csv
  end
end
