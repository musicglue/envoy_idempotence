require_relative 'test_helper'
require_relative '../lib/envoy_idempotence/publisher'

publisher = EnvoyIdempotence::Publisher

describe publisher do
  class StubDocket
    def initialize topics
      @topics = {}
      topics.each { |topic| @topics[topic] = StubTopic.new }
    end

    attr_reader :topics

    class StubTopic
      def publish json
        published << ActiveSupport::JSON.decode(json)
        OpenStruct.new data: { success: true }
      end

      def published
        @published ||= []
      end
    end
  end

  describe 'when there are no messages to be published' do
    before do
      PublishedMessage.delete_all
      @published_messages = publisher.new.publish
    end

    it 'does not publish any messages' do
      PublishedMessage.count.must_equal 0
    end
  end

  describe 'when there are messages to be published' do
    before do
      @message_1 = PublishedMessage.create!(topic: 'topic_a', message: { foo: 'bar-a' })
      @message_2 = PublishedMessage.create!(topic: 'topic_b', message: { foo: 'bar-b' })
      @message_3 = PublishedMessage.create!(topic: 'topic_c', message: { foo: 'bar-c' })
      @message_4 = PublishedMessage.create!(topic: 'topic_d', message: { foo: 'bar-d' })
      @message_5 = PublishedMessage.create!(topic: 'topic_e', message: { foo: 'bar-e' })

      @docket = StubDocket.new(%w(topic_a topic_b topic_c topic_d topic_e))
      @publisher = publisher.new(limit: 2, docket_client: @docket)
      @published_messages = @publisher.publish
    end

    it 'the set of published messages must match the limit attribute' do
      @published_messages.size.must_equal 2
    end

    it 'the published messages are the earliest created' do
      @published_messages.must_include @message_1
      @published_messages.must_include @message_2
    end

    it 'publishes the messages to sqs using docket' do
      @docket.topics['topic_a'].published.count.must_equal 1
      @docket.topics['topic_a'].published.first['foo'].must_equal 'bar-a'
      @docket.topics['topic_b'].published.count.must_equal 1
      @docket.topics['topic_b'].published.first['foo'].must_equal 'bar-b'
      @docket.topics['topic_c'].published.count.must_equal 0
      @docket.topics['topic_d'].published.count.must_equal 0
      @docket.topics['topic_e'].published.count.must_equal 0
    end

    describe 'a second invocation' do
      before do
        @published_messages_2 = @publisher.publish
      end

      it 'does not publish any of the already published messages' do
        @published_messages_2.wont_include @message_1
        @published_messages_2.wont_include @message_2
      end

      it 'the set of published messages must match the limit attribute' do
        @published_messages_2.size.must_equal 2
      end

      it 'the published messages are the earliest created that are still unsent' do
        @published_messages_2.must_include @message_3
        @published_messages_2.must_include @message_4
      end

      it 'marks the messages as attempted' do
        @published_messages_2.all? { |m| m.attempts.must_equal 1 }
      end

      it 'marks the messages as published' do
        @published_messages_2.all? { |m| m.published_at.must_be :present? }
      end

      it 'stores the response on the message' do
        @published_messages_2.all? { |m| m.response.wont_be :nil? }
      end
    end
  end
end
