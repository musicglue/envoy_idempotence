require_relative 'test_helper'
require_relative '../lib/envoy_idempotence/middleware'

middleware = EnvoyIdempotence::Middleware

describe middleware do
  class StubChain
    def called?
      !!@called
    end

    def call(*)
      @called = true
    end
  end

  class StubMessage
    def initialize id, queue
      @id, @queue = id, queue
    end

    def headers
      to_h[:headers]
    end

    attr_reader :id, :queue

    def to_h
      {
        headers: { id: @id },
        body: {}
      }
    end
  end

  class StubWorker
    def initialize message
      @message = message
    end

    attr_reader :message
  end

  before do
    @message_id = SecureRandom.uuid
    @queue_name = SecureRandom.uuid
    @chain = StubChain.new
    @message = StubMessage.new @message_id, @queue_name
    @worker = StubWorker.new @message
    @middleware = middleware.new @chain, @worker, Logger.new('/tmp/envoy_idempotence_test.log')
  end

  describe 'when the message has not already been processed' do
    it 'processes the message' do
      @middleware.call({})
      @chain.called?.must_equal true
    end
  end

  describe 'when the message has already been processed' do
    describe 'on a different queue' do
      before do
        ProcessedMessage.log StubMessage.new(@message_id, SecureRandom.uuid)
      end

      it 'processes the message' do
        @middleware.call({})
        @chain.called?.must_equal true
      end
    end

    describe 'on the same queue' do
      before do
        ProcessedMessage.log @message
      end

      it 'does not process the message' do
        @middleware.call({})
        @chain.called?.must_equal false
      end
    end
  end
end
