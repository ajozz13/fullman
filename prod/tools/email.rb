require 'net/smtp'

class StandardEmail
  attr_accessor :from, :to, :subject, :message
  attr_reader :smtp_server, :user, :pass

  def initialize
    @smtp_server = "smtp.ibcinc.com"
  end

  def send_message
    begin
      print "Send Message to: #{ @to }...."
      # Dont use << you have to use <<-
      # this works %{} but it does not pass email correctly
      # also ensure you don't leave spaces.
msg=<<-MSG
From: #{@from}
To: #{@to}
Subject: #{@subject}

#{@message}
MSG
      Net::SMTP.start( @smtp_server ) do |smtp|
        smtp.send_message msg, @from, @to
      end
      puts "Done."

    rescue Exception => exception
      STDERR.write "Exception: #{ exception }\n"
      puts exception.backtrace
      raise exception
    end
  end

end
