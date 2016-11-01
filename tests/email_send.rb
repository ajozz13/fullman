=begin
  Simple test of the email sending class
=end
require_relative '../prod/tools/email.rb'
exit_code = 0
begin
  email = StandardEmail.new
  email.from = 'aochoa@ibcinc.com'
  email.to = 'ajozz13@gmail.com'
  email.subject = "simple test"

  email.message = "This is a long message\nWith lots of info."

  email.send_message

rescue Exception => e
        puts "Exception: #{e}"
        e.backtrace
        exit_code = 2
ensure
  exit exit_code
end
