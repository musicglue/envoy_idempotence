require 'envoy'
require 'envoy/active_record'
require 'envoy_idempotence/publisher'
require 'envoy_idempotence/publisher_worker' if defined?(::Celluloid)
require 'envoy_idempotence/middleware'
require 'envoy_idempotence/transactional_message'

Envoy::Message.send :include, EnvoyIdempotence::TransactionalMessage

module EnvoyIdempotence
end
