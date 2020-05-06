=begin
  This is a simplistic definition of the IBC AAMS submit object
=end
require 'json'

module IBC
  module AAMS
    def to_manifest_hash aams_email, email_list, man_line, manifest_data
      h = Hash.new
      h[ 'assigned_email' ] = aams_email
      h[ 'to_email' ] = email_list
      h[ 'manifest' ] = to_manifest_array man_line, manifest_data
      return h
    end

    def to_manifest_array man_line, manifest_data
      a = Array.new
      a << to_manifest_object( man_line, manifest_data )
    end

    def to_manifest_object man_line, manifest_data
      { "manifest_line" => man_line, "manifest_data" => manifest_data }
    end

    #This function is the new object for tests
    def setup_manifest_object path_to_file, email_address
        { "email" => email_address, "manifest_data" => File.read( path_to_file ) }.to_json
    end
  end
end
