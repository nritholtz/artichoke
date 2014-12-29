module Artichoke
  class Message

    def initialize(message)
      @message = message
    end

    def attachment_name
      attachments.first.filename
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