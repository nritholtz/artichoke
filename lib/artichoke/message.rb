module Artichoke
  class Message

    def initialize(message)
      @message = message
    end

    def attachment_name
      attachments.first.filename
    end

    def message_content
      text_part.try(:decoded) || html_part.try(:decoded) || body.decoded
    end

    private
     # Delegate all other methods to the Gmail message
    def method_missing(*args, &block)
      if block_given?
        @message.send(*args, &block)
      else
        @message.send(*args)
      end
    end
  end
end