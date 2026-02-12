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

ActiveRecord::Schema[8.1].define(version: 2026_02_12_080546) do
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

  create_table "hare_entries", force: :cascade do |t|
    t.integer "awarded_points", default: 0, null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.date "occurred_on", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "visibility", default: 0, null: false
    t.index ["user_id"], name: "index_hare_entries_on_user_id"
  end

  create_table "hare_entry_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "hare_entry_id", null: false
    t.bigint "hare_tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["hare_entry_id", "hare_tag_id"], name: "index_hare_entry_tags_on_hare_entry_id_and_hare_tag_id", unique: true
    t.index ["hare_entry_id"], name: "index_hare_entry_tags_on_hare_entry_id"
    t.index ["hare_tag_id"], name: "index_hare_entry_tags_on_hare_tag_id"
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

  create_table "meal_searches", force: :cascade do |t|
    t.integer "cook_context"
    t.datetime "created_at", null: false
    t.integer "genre_id"
    t.integer "meal_mode"
    t.integer "mood_id"
    t.text "presented_candidate_names"
    t.integer "required_minutes"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_meal_searches_on_user_id"
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

  create_table "point_rules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_active", default: true, null: false
    t.string "key", null: false
    t.string "label", null: false
    t.json "params"
    t.integer "points", null: false
    t.integer "priority", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_point_rules_on_key", unique: true
    t.index ["priority"], name: "index_point_rules_on_priority"
  end

  create_table "point_transactions", force: :cascade do |t|
    t.date "awarded_on", null: false
    t.datetime "created_at", null: false
    t.bigint "hare_entry_id", null: false
    t.bigint "point_rule_id", null: false
    t.integer "points", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["hare_entry_id"], name: "index_point_transactions_on_hare_entry_id"
    t.index ["point_rule_id"], name: "index_point_transactions_on_point_rule_id"
    t.index ["user_id"], name: "index_point_transactions_on_user_id"
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

  add_foreign_key "hare_entries", "users"
  add_foreign_key "hare_entry_tags", "hare_entries"
  add_foreign_key "hare_entry_tags", "hare_tags"
  add_foreign_key "meal_candidates", "genres"
  add_foreign_key "meal_searches", "users"
  add_foreign_key "point_transactions", "hare_entries"
  add_foreign_key "point_transactions", "point_rules"
  add_foreign_key "point_transactions", "users"
end
