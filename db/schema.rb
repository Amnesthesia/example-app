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

ActiveRecord::Schema[7.0].define(version: 2025_04_15_220320) do
  create_table "appointment_guests", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "appointment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointment_guests_on_appointment_id"
    t.index ["user_id"], name: "index_appointment_guests_on_user_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.string "title"
    t.string "state", default: "draft"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "organization_id"
    t.integer "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_time"], name: "index_appointments_on_end_time"
    t.index ["organization_id"], name: "index_appointments_on_organization_id"
    t.index ["owner_id"], name: "index_appointments_on_owner_id"
    t.index ["start_time"], name: "index_appointments_on_start_time"
    t.index ["state"], name: "index_appointments_on_state"
    t.index ["title"], name: "index_appointments_on_title"
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_families_on_name"
    t.index ["organization_id"], name: "index_families_on_organization_id"
  end

  create_table "family_members", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "family_id", null: false
    t.string "visibility", default: "staff"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_members_on_family_id"
    t.index ["user_id"], name: "index_family_members_on_user_id"
    t.index ["visibility"], name: "index_family_members_on_visibility"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "encrypted_password"
    t.string "password_digest"
    t.string "role"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["encrypted_password"], name: "index_users_on_encrypted_password"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["password_digest"], name: "index_users_on_password_digest"
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "appointment_guests", "appointments"
  add_foreign_key "appointment_guests", "users"
  add_foreign_key "appointments", "users", column: "owner_id"
  add_foreign_key "family_members", "families"
  add_foreign_key "family_members", "users"
end
