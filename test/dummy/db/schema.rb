# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140912091944) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "processed_messages", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "message_id", null: false
    t.string   "queue",      null: false
    t.json     "message",    null: false
  end

  add_index "processed_messages", ["message_id", "queue"], name: "index_processed_messages_on_message_id_and_queue", unique: true, using: :btree

  create_table "published_messages", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "topic",                    null: false
    t.json     "message",                  null: false
    t.json     "response"
    t.integer  "attempts",     default: 0, null: false
    t.datetime "attempted_at"
    t.string   "published_by"
    t.datetime "published_at"
  end

  add_index "published_messages", ["published_at"], name: "index_published_messages_on_published_at", using: :btree
  add_index "published_messages", ["published_by"], name: "index_published_messages_on_published_by", using: :btree

end
