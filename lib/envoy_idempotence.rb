require 'docket'
require 'envoy_idempotence/publisher'
require 'envoy_idempotence/publisher_worker' if defined?(::Celluloid)
require 'envoy_idempotence/middleware'
require 'envoy_idempotence/transactional_message'

Docket::Message.send :include, EnvoyIdempotence::TransactionalMessage

module EnvoyIdempotence
end
