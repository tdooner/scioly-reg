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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110117040525) do

  create_table "schedules", :force => true do |t|
    t.string   "event"
    t.integer  "tournament_id"
    t.string   "division"
    t.time     "starttime"
    t.time     "endtime"
    t.integer  "timeslots"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "room"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sign_ups", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "team_id"
    t.time     "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "number"
    t.string   "division"
    t.string   "coach"
    t.string   "hashed_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tournament_id"
  end

  create_table "tournaments", :force => true do |t|
    t.date     "date"
    t.boolean  "is_current"
    t.datetime "registration_begins"
    t.datetime "registration_ends"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.text    "case_id"
    t.integer "role",       :default => 0
    t.text    "created_at"
    t.text    "updated_at"
  end

end
