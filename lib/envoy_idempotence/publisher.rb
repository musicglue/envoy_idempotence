module EnvoyIdempotence
  class Publisher
    def initialize limit: 10, docket_client: Docket, logger: Envoy::Logging
      @limit = limit
      @docket = docket_client
      @publisher_id = ENV['DYNO'] || "publisher"
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
          response = @docket.topics[message.topic].publish message.message.to_json
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
