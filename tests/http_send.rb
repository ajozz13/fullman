=begin
  Simple test of the email sending class
=end
require_relative '../prod/tools/http_send.rb'
require_relative '../prod/def/ibc_aams.rb'
include IBC::AAMS

exit_code = 0
begin
  man_line = "1,1034644,20140821,MIA,BUE,AA544,12573370091"
  manifest_data = "8,,277079283,,,,LHR,SAO ,,,,1,0.5,P,DOC,,,,,P,P,ST,,,,,,STILL DIFFERENT CO INC,1234 NEW ROAD,,FRANKFURT,,,DE, 49691231234,RUBENS ANDRADE,COMPANY 82,AV PAULISTA 2300 4TH 5TH FLRS,,SAO PAULO ,SP,01310-300,BR,,\n8,,278975857,,,,LHR,SAO,,,,1,0.5,P,DOC,,,,,P,P,ST,,,,,,STILL DIFFERENT CO INC,1234 NEW ROAD,,FRANKFURT,,,DE, 49691231234,ADEMAR RIBEIRO, COMPANY 83,AV MARIA COELHO AGUIAR 215 BLOCO,C-2 ANDAR,SAO PAULO ,SP,05805-000,BR,,\n8,,280872431,,,,LHR,SAO,,,,1,0.5,P,DOC,,,,,P,P,ST,,,,,,STILL DIFFERENT CO INC, 1234 NEW ROAD,,FRANKFURT,,,DE, 49691231234,CARLOS GULLO,COMPANY 84,AV MARIA COELHO AGUIAR 215 BLOCO,C-2 ANDAR,SAO PAULO ,SP,05805-000,BR,,\n"
  ibc_aams = IBC::AAMS.to_manifest_hash( "it@ibcinc.com", "ajozz13@gmail.com", man_line, manifest_data )

  #This is a test of the IBC:AAMS module setup
  puts ibc_aams.inspect

  sender = HTTPSender.new true  #with debug mode on
  sender.url = "https://api.pactrak.com/manifest/aams?_test"
  sender.method = "POST"
  sender.headers = { "Content-Type" => "application/json" }
  sender.content = ibc_aams

  sender.execute

rescue Exception => e
        puts "Exception: #{e}"
        e.backtrace
        exit_code = 2
ensure
  exit exit_code
end
