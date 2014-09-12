require_relative 'test_helper'
require_relative '../lib/generators/envoy_idempotence/templates/published_message'

class ImportantMessage
  include Docket::Message

  def attributes
    { money: 100 }
  end
end

describe EnvoyIdempotence::TransactionalMessage do
  describe 'when a message is published transactionally' do
    before do
      ImportantMessage.new.publish_transactionally
    end

    it 'is unsent' do
      PublishedMessage.unsent.count.must_equal 1
    end

    describe 'the message' do
      before do
        @message = PublishedMessage.unsent.first
      end

      it 'has the correct topic' do
        @message.topic.must_equal 'important'
      end

      it 'has the correct payload' do
        @message.message['body']['money'].must_equal 100
      end
    end
  end
end
