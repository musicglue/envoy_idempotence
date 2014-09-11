class EnvoyIdempotenceCreatePublishedMessages < ActiveRecord::Migration
  def change
    create_table :published_messages, id: :uuid do |t|
      t.timestamps

      t.string :topic, null: false
      t.json :message, null: false
      t.json :response

      t.string :published_by

      t.datetime :attempted_at
      t.datetime :published_at

      t.index :published_by
      t.index :published_at
    end
  end
end
