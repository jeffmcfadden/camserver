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

ActiveRecord::Schema.define(version: 20160920210432) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cameras", force: :cascade do |t|
    t.string   "name"
    t.integer  "camera_type"
    t.string   "ip_address"
    t.string   "username"
    t.string   "password"
    t.string   "port"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "motion_events", force: :cascade do |t|
    t.integer  "camera_id"
    t.boolean  "favorite",                   default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "video_01_filename"
    t.text     "video_01_file_path"
    t.integer  "video_01_size"
    t.text     "video_01_original_filename"
    t.boolean  "video_01_stored_privately"
    t.string   "video_01_type"
    t.string   "image_01_filename"
    t.text     "image_01_file_path"
    t.integer  "image_01_size"
    t.text     "image_01_original_filename"
    t.boolean  "image_01_stored_privately"
    t.string   "image_01_type"
    t.string   "image_02_filename"
    t.text     "image_02_file_path"
    t.integer  "image_02_size"
    t.text     "image_02_original_filename"
    t.boolean  "image_02_stored_privately"
    t.string   "image_02_type"
    t.string   "image_03_filename"
    t.text     "image_03_file_path"
    t.integer  "image_03_size"
    t.text     "image_03_original_filename"
    t.boolean  "image_03_stored_privately"
    t.string   "image_03_type"
    t.string   "image_04_filename"
    t.text     "image_04_file_path"
    t.integer  "image_04_size"
    t.text     "image_04_original_filename"
    t.boolean  "image_04_stored_privately"
    t.string   "image_04_type"
    t.string   "image_05_filename"
    t.text     "image_05_file_path"
    t.integer  "image_05_size"
    t.text     "image_05_original_filename"
    t.boolean  "image_05_stored_privately"
    t.string   "image_05_type"
    t.string   "image_06_filename"
    t.text     "image_06_file_path"
    t.integer  "image_06_size"
    t.text     "image_06_original_filename"
    t.boolean  "image_06_stored_privately"
    t.string   "image_06_type"
    t.datetime "occurred_at"
    t.boolean  "processed",                  default: false
    t.string   "data_directory"
    t.index ["camera_id", "occurred_at"], name: "index_motion_events_on_camera_id_and_occurred_at", using: :btree
    t.index ["camera_id"], name: "index_motion_events_on_camera_id", using: :btree
    t.index ["occurred_at"], name: "index_motion_events_on_occurred_at", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "motion_events", "cameras"
end
