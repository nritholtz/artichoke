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


    ### poller.find({message_subject: "Sample Email", timeout:75, content:["specific positioning", "footer"], 
    ###              attachments:["picture.jpg", "spreadsheet.csv"], skip_error: false, partial_subject_match: true})
    def find(options={})
      raise ArgumentError.new("Email Subject required") unless options[:message_subject]
      begin
        Timeout::timeout(options[:timeout]|| 75) do
          while true do
            client do
              gm_string = generate_gm_string(@gmail_start_time, options)
              @gmail.inbox.emails(:gm => gm_string).each do |email|
                message = email.message
                return Message.new(message) if message_match?(message, options)
              end
            end
          end
        end
      rescue Timeout::Error => e
        raise "No email was found with subject: #{options[:message_subject]} >= #{@gmail_start_time}, content(s): #{options[:content]||'N/A'}, attachment(s) #{options[:attachments]||'N/A'}"  unless options[:skip_error]
      end
    end

    ### poller.count({message_subject: "Sample Email", content:["specific positioning", "footer"], 
    ###              attachments:["picture.jpg", "spreadsheet.csv"], partial_subject_match: true})
    def count(options={})
      client do
        gm_string = generate_gm_string(@gmail_start_time, options)
        count = 0
        @gmail.inbox.emails(:gm => gm_string).each do |email|
          count += 1 if message_match?(email.message, options)
        end
        return count
      end
    end

    protected
    def generate_gm_string(start_time, options={})
      gm_string = "newer:#{start_time.to_i} subject:"+options[:message_subject]+" "
      if options[:attachments]
        options[:attachments].each{|attachment| gm_string += attachment+" "} 
        gm_string+= " has:attachment"
      end
      if options[:end_time]
        gm_string+= " older:#{options[:end_time].to_i}"
      end
      gm_string
    end

    def message_match?(message, options)
      if (message.date.to_i >= @gmail_start_time.to_i) && (options[:partial_subject_match] || message.subject == options[:message_subject])
        body = (message.text_part.try(:decoded) || message.html_part.try(:decoded) || message.body.to_s.force_encoding('utf-8'))
        (options[:content]|| []).all?{|c| body =~ /#{Regexp.escape(c)}/} ? true : false
      else
        false
      end
    end
  end
end