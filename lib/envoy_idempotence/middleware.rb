module EnvoyIdempotence
  class Middleware
    def initialize app, worker, logger = Envoy::Logging
      @app = app
      @worker = worker
      @logger = logger
    end

    def call env
      if ProcessedMessage.exists? message_id: message_id, queue: queue
        @logger.warn component: 'envoy_idempotence_middleware', at: 'call', ignored_message_id: message_id
      else
        @app.call env
        ProcessedMessage.log @worker.message
      end
    end

    private

    def message_id
      @worker.message.id
    end

    def queue
      @worker.message.queue
    end
  end
end
