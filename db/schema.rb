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

ActiveRecord::Schema[7.2].define(version: 2025_09_05_183852) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "reservations", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "reservation_type", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.decimal "cost", precision: 10, scale: 2
    t.string "country", null: false
    t.string "city"
    t.string "confirmation_number"
    t.text "notes"
    t.string "status", default: "planned"
    t.bigint "user_id", null: false
    t.bigint "tribe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reservation_type"], name: "index_reservations_on_reservation_type"
    t.index ["start_date"], name: "index_reservations_on_start_date"
    t.index ["status"], name: "index_reservations_on_status"
    t.index ["tribe_id", "start_date"], name: "index_reservations_on_tribe_id_and_start_date"
    t.index ["tribe_id"], name: "index_reservations_on_tribe_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "tribes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "invite_code", null: false
    t.string "destination"
    t.date "start_date"
    t.date "end_date"
    t.decimal "total_budget", precision: 10, scale: 2
    t.decimal "current_expenses", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_code"], name: "index_tribes_on_invite_code", unique: true
    t.index ["name"], name: "index_tribes_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.boolean "admin", default: false
    t.bigint "tribe_id", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tribe_id"], name: "index_users_on_tribe_id"
  end

  create_table "vision_board_items", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "image_url"
    t.string "link_url"
    t.string "item_type", default: "inspiration"
    t.integer "priority", default: 1
    t.boolean "achieved", default: false
    t.bigint "user_id", null: false
    t.bigint "tribe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achieved"], name: "index_vision_board_items_on_achieved"
    t.index ["item_type"], name: "index_vision_board_items_on_item_type"
    t.index ["priority"], name: "index_vision_board_items_on_priority"
    t.index ["tribe_id", "priority"], name: "index_vision_board_items_on_tribe_id_and_priority"
    t.index ["tribe_id"], name: "index_vision_board_items_on_tribe_id"
    t.index ["user_id"], name: "index_vision_board_items_on_user_id"
  end

  add_foreign_key "reservations", "tribes"
  add_foreign_key "reservations", "users"
  add_foreign_key "users", "tribes"
  add_foreign_key "vision_board_items", "tribes"
  add_foreign_key "vision_board_items", "users"
end
