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

ActiveRecord::Schema.define(version: 20151123201416) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "archive_formats", force: :cascade do |t|
    t.integer  "profile_id",         null: false
    t.string   "audio_format",       null: false
    t.integer  "initial_bitrate",    null: false
    t.integer  "initial_channels",   null: false
    t.integer  "max_public_bitrate"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["profile_id"], name: "index_archive_formats_on_profile_id", using: :btree
  end

  create_table "audio_files", force: :cascade do |t|
    t.integer  "broadcast_id",       null: false
    t.string   "path",               null: false
    t.string   "audio_format",       null: false
    t.integer  "bitrate",            null: false
    t.integer  "channels",           null: false
    t.integer  "playback_format_id"
    t.datetime "created_at",         null: false
    t.index ["broadcast_id"], name: "index_audio_files_on_broadcast_id", using: :btree
    t.index ["playback_format_id"], name: "index_audio_files_on_playback_format_id", using: :btree
  end

  create_table "broadcasts", force: :cascade do |t|
    t.integer  "show_id",     null: false
    t.string   "label",       null: false
    t.datetime "started_at",  null: false
    t.datetime "finished_at", null: false
    t.string   "people"
    t.text     "details"
    t.index ["show_id"], name: "index_broadcasts_on_show_id", using: :btree
  end

  create_table "downgrade_actions", force: :cascade do |t|
    t.integer "archive_format_id", null: false
    t.integer "months",            null: false
    t.integer "bitrate"
    t.integer "channels"
    t.index ["archive_format_id"], name: "index_downgrade_actions_on_archive_format_id", using: :btree
  end

  create_table "playback_formats", force: :cascade do |t|
    t.string   "name",         null: false
    t.text     "description"
    t.string   "audio_format", null: false
    t.integer  "bitrate",      null: false
    t.integer  "channels",     null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "name",                        null: false
    t.text     "description"
    t.boolean  "default",     default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "shows", force: :cascade do |t|
    t.string  "name",       null: false
    t.text    "details"
    t.integer "profile_id", null: false
    t.index ["profile_id"], name: "index_shows_on_profile_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",           null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "groups"
    t.string   "api_key"
    t.datetime "api_key_expires_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_foreign_key "archive_formats", "profiles", on_delete: :cascade
  add_foreign_key "audio_files", "archive_formats", on_delete: :restrict
  add_foreign_key "audio_files", "broadcasts", on_delete: :restrict
  add_foreign_key "audio_files", "playback_formats", on_delete: :nullify
  add_foreign_key "broadcasts", "shows", on_delete: :restrict
  add_foreign_key "downgrade_actions", "archive_formats", on_delete: :cascade
  add_foreign_key "shows", "profiles", on_delete: :restrict
end
