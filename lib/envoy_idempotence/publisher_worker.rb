module EnvoyIdempotence
  class PublisherWorker
    include Celluloid
    include Envoy::Logging

    def initialize
      @publisher = EnvoyIdempotence::Publisher.new
    end

    def start
      until @stopping
        message_count = @publisher.publish.count

        debug(
          component: 'publisher_worker',
          at: 'after_publish',
          sent_count: message_count
        ) if message_count > 0

        sleep 1 if message_count == 0
      end
    end

    def stop
      @stopping = true
    end
  end
end
