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

ActiveRecord::Schema.define(version: 20170321094010) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "uuid-ossp"

  create_table "archive_assets", force: :cascade do |t|
    t.uuid     "archive_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "qgis_id"
    t.integer  "qgis_group_id"
  end

  create_table "archive_tags", force: :cascade do |t|
    t.uuid     "archive_id"
    t.uuid     "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "archives", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer   "category_id"
    t.uuid      "license_id"
    t.string    "name",                         limit: 100
    t.text      "description"
    t.string    "author",                       limit: 100
    t.string    "owner",                        limit: 100
    t.integer   "created_begin_on_y"
    t.integer   "created_begin_on_m"
    t.integer   "created_begin_on_d"
    t.integer   "created_end_on_y"
    t.integer   "created_end_on_m"
    t.integer   "created_end_on_d"
    t.text      "location"
    t.geography "lonlat",                       limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.text      "note"
    t.string    "represent_image_file_name"
    t.string    "represent_image_content_type"
    t.integer   "represent_image_file_size"
    t.datetime  "represent_image_updated_at"
    t.boolean   "enabled",                                                                               default: false
    t.integer   "qgis_id"
    t.integer   "qgis_group_id"
    t.integer   "updated_user_id"
    t.datetime  "created_at",                                                                                            null: false
    t.datetime  "updated_at",                                                                                            null: false
    t.index ["category_id"], name: "index_archives_on_category_id", using: :btree
    t.index ["updated_user_id"], name: "index_archives_on_updated_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.integer  "code"
    t.string   "name",       limit: 30
    t.boolean  "enabled",               default: true
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "import_job_errors", force: :cascade do |t|
    t.integer  "import_job_id"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "import_jobs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licenses", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "code"
    t.string   "name"
    t.integer  "content_type", default: 0
    t.text     "content"
    t.boolean  "enabled",      default: true
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "tag_black_lists", force: :cascade do |t|
    t.string   "name",       limit: 100
    t.boolean  "enabled",                default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "tags", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",       limit: 100
    t.boolean  "enabled",                default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "name",              limit: 50
    t.string   "login",             limit: 30
    t.integer  "role",                         default: 0
    t.string   "password_digest"
    t.datetime "last_logged_in_at"
    t.boolean  "enabled",                      default: true
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

end
