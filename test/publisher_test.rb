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
      @published_messages = publisher.new(limit: 2, docket_client: @docket).publish
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
      it 'does not publish any of the already published messages' do

      end
    end
  end
end
