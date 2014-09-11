module EnvoyIdempotence
  class Publisher
    def initialize limit: 10, docket_client: Docket
      @limit = limit
      @docket = docket_client
    end

    def publish
      PublishedMessage.unsent.limit(@limit).each do |message|
        @docket.topics[message.topic].publish message.message.to_json
      end
    end
  end
end
