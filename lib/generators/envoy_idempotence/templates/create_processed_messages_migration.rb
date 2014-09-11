class EnvoyIdempotenceCreateProcessedMessages < ActiveRecord::Migration
  def change
    create_table :processed_messages, id: :uuid do |t|
      t.timestamps

      t.uuid :message_id, null: false
      t.string :queue, null: false
      t.json :message, null: false

      t.index %i(message_id queue), unique: true
    end
  end
end
