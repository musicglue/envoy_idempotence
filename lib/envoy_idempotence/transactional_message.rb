module EnvoyIdempotence
  module TransactionalMessage
    def publish_transactionally
      PublishedMessage.create!(
        topic: topic_name,
        message: to_h)
    end
  end
end
