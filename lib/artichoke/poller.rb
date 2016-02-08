module Artichoke
  class Poller

    def initialize
      @gmail_start_time = DateTime.now
    end


    def client
      username = Artichoke::Connection.client_username
      password = Artichoke::Connection.client_password
      begin
        @gmail = Gmail.new(username, password)
        @gmail.peek = true
        yield
      #Retry for intermittent Gmail issues
      rescue Net::IMAP::ByeResponseError, Net::IMAP::NoResponseError => e
        puts "Artichoke: Retrying after #{e.inspect}"
        retry
      ensure      
        @gmail.disconnect
      end
    end


    ### poller.find({message_subject: "Sample Email", timeout:75, content:["specific positioning", "footer"], attachments:["picture.jpg", "spreadsheet.csv"], skip_error: false})
    def find(options={})
      raise ArgumentError.new("Email Subject required") unless options[:message_subject]
      begin
        Timeout::timeout(options[:timeout]|| 75) do
          while true do
            client do
              gm_string = "newer:#{@gmail_start_time.to_i} subject:"+options[:message_subject]+" "
              if options[:attachments]
                options[:attachments].each{|attachment| gm_string += attachment+" "} 
                gm_string+= " has:attachment"
              end
              @gmail.inbox.emails(:gm => gm_string).each do |email|
                message = email.message
                if (message.date.to_i >= @gmail_start_time.to_i) && (message.subject == options[:message_subject])
                  body = (message.text_part.try(:decoded) || message.html_part.try(:decoded) || message.body.to_s.force_encoding('utf-8'))
                  return Message.new(message) if (options[:content]|| []).all?{|c| body =~ /#{Regexp.escape(c)}/}
                end
              end
            end
          end
        end
      rescue Timeout::Error => e
        raise "No email was found with subject: #{options[:message_subject]} >= #{@gmail_start_time}, content(s): #{options[:content]||'N/A'}, attachment(s) #{options[:attachments]||'N/A'}"  unless options[:skip_error]
      end
    end
  end
end