require 'rails/generators/active_record/migration'

module EnvoyIdempotence
  class InstallGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration

    desc 'Create the idempotence models for Envoy'

    source_root File.expand_path('../templates', __FILE__)

    def install_files
      copy_file 'processed_message.rb', 'app/models/processed_message.rb'
      copy_file 'published_message.rb', 'app/models/published_message.rb'

      migration_template "create_processed_messages_migration.rb",
                         "db/migrate/envoy_idempotence_create_processed_messages.rb"

      migration_template "create_published_messages_migration.rb",
                         "db/migrate/envoy_idempotence_create_published_messages.rb"
    end
  end
end
