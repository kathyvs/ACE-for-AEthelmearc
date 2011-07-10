# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110707042838) do

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.datetime "posted"
    t.integer  "reply_to"
    t.integer  "submission_id"
    t.integer  "user_id"
    t.datetime "edited"
    t.string   "img1"
    t.string   "img2"
    t.string   "img3"
  end

  create_table "letters", :force => true do |t|
    t.text   "comments"
    t.date   "posted"
    t.date   "locked"
    t.string "issue"
  end

  create_table "news", :force => true do |t|
    t.text     "content"
    t.datetime "posted"
    t.integer  "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sub_types", :force => true do |t|
    t.string "name",   :null => false
    t.string "abbrev", :null => false
  end

  create_table "submissions", :force => true do |t|
    t.string  "filing_name"
    t.text    "content"
    t.boolean "draft_flag",  :default => true
    t.integer "user_id"
    t.integer "letter_id"
    t.integer "sub_type_id"
    t.boolean "resub_flag"
    t.string  "summary"
    t.string  "bwimg"
    t.string  "colorimg"
    t.string  "email"
  end

  create_table "users", :force => true do |t|
    t.string  "login"
    t.string  "encrypted_password"
    t.boolean "submit_flag",        :default => false
    t.boolean "valid_flag",         :default => false
    t.boolean "admin_flag",         :default => false
    t.string  "sca_name",                              :null => false
    t.string  "mundane_name"
    t.string  "email"
    t.string  "title"
    t.boolean "mailok_flag",        :default => false
    t.boolean "archived_flag",      :default => false
  end

end
