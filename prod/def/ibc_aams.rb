=begin
  This is a simplistic definition of the IBC AAMS submit object
=end
module IBC
  module AAMS
    def to_manifest_hash aams_email, email_list, man_line, manifest_data
      h = Hash.new
      h[ 'email_rport' ] = aams_email
      h[ 'to_email' ] = email_list
      h[ 'manifest' ] = to_manifest_array man_line, manifest_data
      return h
    end

    def to_manifest_array man_line, manifest_data
      a = Array.new
      a << to_manifest_object( man_line, manifest_data )
    end

    def to_manifest_object man_line, manifest_data
      { "man_line" => man_line, "m_tdata" => manifest_data }
    end
  end
end
