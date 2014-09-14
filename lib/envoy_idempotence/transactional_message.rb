module EnvoyIdempotence
  module TransactionalMessage
    extend ActiveSupport::Concern

    included do
      def self.unsent
        PublishedMessage.unsent.where(topic: topic_name)
      end
    end

    def publish_transactionally
      PublishedMessage.create!(
        topic: topic_name,
        message: to_h)
    end
  end
end
