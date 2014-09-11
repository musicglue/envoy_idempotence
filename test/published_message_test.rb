require_relative 'test_helper'
require_relative '../lib/generators/envoy_idempotence/templates/published_message'

describe PublishedMessage do
  describe '#unsent scope' do
    describe 'when there are no messages' do
      it 'does not publish any messages' do
        PublishedMessage.unsent.count.must_equal 0
      end
    end

    describe 'when a message is created' do
      before do
        @message = PublishedMessage.create!(topic: 'topic_a', message: { foo: 'bar-a' })
        @unsent = PublishedMessage.unsent.to_a
      end

      it 'exists' do
        PublishedMessage.all.count.must_equal 1
      end

      it 'is unsent' do
        @unsent.count.must_equal 1
        @unsent.first.id.must_equal @message.id
      end
    end

    describe 'when a message has been attempted in the last minute' do
      before do
        @message = PublishedMessage.create!(topic: 'topic_a', message: { foo: 'bar-a' }, attempted_at: 1.second.ago)
        @unsent = PublishedMessage.unsent.to_a
      end

      it 'exists' do
        PublishedMessage.all.count.must_equal 1
      end

      it 'is not unsent' do
        @unsent.count.must_equal 0
      end
    end

    describe 'when a message has been attempted more than a minute ago' do
      before do
        @message = PublishedMessage.create!(topic: 'topic_a', message: { foo: 'bar-a' }, attempted_at: 2.minutes.ago)
        @unsent = PublishedMessage.unsent.to_a
      end

      it 'exists' do
        PublishedMessage.all.count.must_equal 1
      end

      it 'is unsent' do
        @unsent.count.must_equal 1
        @unsent.first.id.must_equal @message.id
      end
    end
  end
end
