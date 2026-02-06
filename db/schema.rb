# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_06_133539) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "genres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.string "key", null: false
    t.string "label", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_genres_on_key", unique: true
    t.index ["label"], name: "index_genres_on_label", unique: true
    t.index ["position"], name: "index_genres_on_position"
  end

  create_table "hare_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.string "key", null: false
    t.string "label", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_hare_tags_on_key", unique: true
    t.index ["label"], name: "index_hare_tags_on_label", unique: true
    t.index ["position"], name: "index_hare_tags_on_position"
  end

  create_table "meal_candidates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "genre_id", null: false
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.integer "position"
    t.string "search_hint"
    t.datetime "updated_at", null: false
    t.index ["genre_id", "name"], name: "index_meal_candidates_on_genre_id_and_name", unique: true
    t.index ["genre_id"], name: "index_meal_candidates_on_genre_id"
    t.index ["position"], name: "index_meal_candidates_on_position"
  end

  create_table "mood_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.string "key", null: false
    t.string "label", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_mood_tags_on_key", unique: true
    t.index ["label"], name: "index_mood_tags_on_label", unique: true
    t.index ["position"], name: "index_mood_tags_on_position"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "meal_candidates", "genres"
end
