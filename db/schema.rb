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

ActiveRecord::Schema.define(version: 20170316070632) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "default_events", force: true do |t|
    t.integer  "year"
    t.string   "name"
    t.string   "division"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "default_events", ["year"], name: "index_default_events_on_year", using: :btree

  create_table "infos", force: true do |t|
    t.string   "name"
    t.text     "page_text"
    t.binary   "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "human_name"
  end

  create_table "schedules", force: true do |t|
    t.string   "event"
    t.integer  "tournament_id"
    t.string   "division"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "room"
    t.boolean  "scores_withheld",  default: false
    t.boolean  "counts_for_score", default: true
    t.text     "custom_info",      default: ""
    t.time     "starttime"
    t.time     "endtime"
  end

  add_index "schedules", ["tournament_id"], name: "index_schedules_on_tournament_id", using: :btree

  create_table "schools", force: true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.string   "admin_name"
    t.string   "admin_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "time_zone",         default: "Eastern Time (US & Canada)"
  end

  add_index "schools", ["subdomain"], name: "index_schools_on_subdomain", using: :btree

  create_table "scores", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "team_id"
    t.integer  "placement"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["schedule_id"], name: "index_scores_on_schedule_id", using: :btree
  add_index "scores", ["team_id"], name: "index_scores_on_team_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sign_ups", force: true do |t|
    t.integer  "timeslot_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sign_ups", ["team_id"], name: "index_sign_ups_on_team_id", using: :btree
  add_index "sign_ups", ["timeslot_id"], name: "index_sign_ups_on_timeslot_id", using: :btree

  create_table "teams", force: true do |t|
    t.string   "name"
    t.string   "number"
    t.string   "division"
    t.string   "coach"
    t.string   "hashed_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tournament_id"
    t.string   "homeroom"
    t.boolean  "qualified",       default: false
    t.string   "email"
  end

  add_index "teams", ["tournament_id", "division"], name: "index_teams_on_tournament_id_and_division", using: :btree

  create_table "timeslots", force: true do |t|
    t.integer  "schedule_id"
    t.datetime "begins"
    t.datetime "ends"
    t.integer  "team_capacity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "timeslots", ["schedule_id"], name: "index_timeslots_on_schedule_id", using: :btree

  create_table "tournaments", force: true do |t|
    t.boolean  "is_current"
    t.datetime "registration_begins"
    t.datetime "registration_ends"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "scores_revealed",                default: false
    t.integer  "school_id"
    t.string   "homepage_photo_file_name"
    t.string   "homepage_photo_content_type"
    t.integer  "homepage_photo_file_size"
    t.datetime "homepage_photo_updated_at"
    t.text     "hosted_by_markdown"
    t.text     "homepage_markdown"
    t.string   "title"
    t.datetime "date"
    t.boolean  "append_division_to_team_number", default: true
  end

  add_index "tournaments", ["school_id", "is_current"], name: "index_tournaments_on_school_id_and_is_current", using: :btree

  create_table "users", force: true do |t|
    t.integer "role",            default: 0
    t.text    "created_at"
    t.text    "updated_at"
    t.integer "school_id"
    t.string  "email"
    t.string  "hashed_password"
  end

  add_index "users", ["school_id", "email", "hashed_password"], name: "index_users_on_school_id_and_email_and_hashed_password", using: :btree

end
