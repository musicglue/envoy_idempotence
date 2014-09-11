class PublisherWorker
  include Celluloid
  include Envoy::Logging

  def initialize
    @publisher = EnvoyIdempotence::Publisher.new
  end

  def run
    until @stopping
      @publisher.publish

      # connections_count = pool.connections.count
      # pool_size = pool.size

      # ::NewRelic::Agent.record_metric 'Custom/connection_pool/active', connections_count
      # ::NewRelic::Agent.record_metric 'Custom/connection_pool/size', pool_size

      # debug "Connection pool: #{connections_count} busy of #{pool_size}" if connections_count > 0
      # sleep 10
    end
  end

  def stop
    @stopping = true
  end

  # def pool
  #   ActiveRecord::Base.connection_pool
  # end
end
