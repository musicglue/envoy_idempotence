module EnvoyIdempotence
  class Middleware
    def initialize app, worker, logger = nil
      @app = app
      @worker = worker
      @logger = logger || Rails.logger
    end

    def call env
      if ProcessedMessage.exists? message_id: message_id, queue: queue
        @logger.warn %(middleware="message_idempotence" at="call" ignored_message_id="#{message_id}")
      else
        @app.call env
      end
    end

    private

    def message_id
      @worker.message.headers[:id]
    end

    def queue
      @worker.message.queue_name
    end
  end
end
