module EnvoyIdempotence
  class Publisher
    def initialize limit: 10, publisher_client: nil, logger: Envoy::Logging
      @limit = limit
      @publisher_id = ENV['DYNO'] || "publisher"
      @publisher = publisher_client || Envoy::MessagePublisher.new
      @logger = logger
    end

    def publish
      timestamp = Time.now

      PublishedMessage.unsent.limit(@limit).update_all(
        published_by: @publisher_id,
        attempted_at: timestamp)

      messages = PublishedMessage.sent_by(@publisher_id, timestamp)
      messages.update_all 'attempts = attempts + 1'

      messages.each do |message|
        begin
          response = @publisher.publish message.message
          message.update! response: response.data.to_hash, published_at: Time.now
        rescue => e
          @logger.error({ component: 'envoy_idempotence_publisher', at: 'publish' }, e)
          message.update! response: { error: e.to_s }
        end
      end

      messages.reload
    end
  end
end
