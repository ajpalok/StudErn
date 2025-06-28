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

ActiveRecord::Schema[8.0].define(version: 2025_06_28_145803) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bkash_payments", force: :cascade do |t|
    t.string "payment_from"
    t.string "payment_id"
    t.string "trx_id"
    t.string "trx_status"
    t.string "amount"
    t.string "verification_status"
    t.string "refund_status"
    t.string "refund_amount"
    t.string "refund_charge"
    t.string "refund_id"
    t.string "refund_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "tagline"
    t.string "description"
    t.string "email"
    t.string "phone"
    t.string "website"
    t.float "latitude"
    t.float "longitude"
    t.integer "parent_company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_company_id"], name: "index_companies_on_parent_company_id"
  end

  create_table "contactforms", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "control_units", force: :cascade do |t|
    t.string "name"
    t.string "nid", null: false
    t.date "dob"
    t.string "address"
    t.string "phone", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "role", default: 99, null: false
    t.boolean "status", default: true, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_control_units_on_confirmation_token", unique: true
    t.index ["email"], name: "index_control_units_on_email", unique: true
    t.index ["reset_password_token"], name: "index_control_units_on_reset_password_token", unique: true
  end

  create_table "recruiter_permissions_on_company", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "recruiter_id", null: false
    t.string "recruiter_position", null: false
    t.time "recruiter_working_start_time"
    t.time "recruiter_working_end_time"
    t.integer "recruiter_status", default: 0
    t.boolean "can_manage_jobs", default: false
    t.boolean "can_manage_applicants", default: false
    t.boolean "can_manage_interviews", default: false
    t.boolean "can_manage_offers", default: false
    t.boolean "can_manage_company_profile", default: false
    t.boolean "can_manage_recruiter_profile", default: false
    t.boolean "can_manage_company_settings", default: false
    t.boolean "can_manage_recruiter_settings", default: false
    t.boolean "can_manage_company_users", default: false
    t.boolean "can_manage_subscriptions_of_studern", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_recruiter_permissions_on_company_on_company_id"
    t.index ["recruiter_id"], name: "index_recruiter_permissions_on_company_on_recruiter_id"
  end

  create_table "recruiters", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.integer "gender", default: 0
    t.integer "account_status", default: 0
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_recruiters_on_confirmation_token", unique: true
    t.index ["email"], name: "index_recruiters_on_email", unique: true
    t.index ["reset_password_token"], name: "index_recruiters_on_reset_password_token", unique: true
  end

  create_table "recruitment_applies", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "recruitment_id", null: false
    t.integer "status", default: 0, null: false
    t.boolean "has_contacted_yet", default: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recruitment_id"], name: "index_recruitment_applies_on_recruitment_id"
    t.index ["user_id", "recruitment_id"], name: "index_recruitment_applies_on_user_and_recruitment_unique", unique: true
    t.index ["user_id"], name: "index_recruitment_applies_on_user_id"
  end

  create_table "recruitments", force: :cascade do |t|
    t.integer "recruitment_type", default: 0, null: false
    t.string "title", null: false
    t.text "description", null: false
    t.integer "experience_level", default: 0, null: false
    t.integer "work_type", default: 0, null: false
    t.integer "work_place", default: 0, null: false
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.integer "salary_type", default: 1, null: false
    t.float "annual_salary_range_start"
    t.float "annual_salary_range_end"
    t.integer "number_of_vacancies", default: 1, null: false
    t.integer "application_collection_status", default: 2
    t.datetime "application_collection_end_date"
    t.integer "application_package", default: 0
    t.integer "application_collection_method", default: 0
    t.string "application_link"
    t.string "calling_number"
    t.integer "company_id", null: false
    t.integer "recruiter_id", null: false
    t.integer "bkash_payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bkash_payment_id"], name: "index_recruitments_on_bkash_payment_id"
    t.index ["company_id"], name: "index_recruitments_on_company_id"
    t.index ["recruiter_id"], name: "index_recruitments_on_recruiter_id"
    t.index ["title"], name: "index_recruitments_on_title"
  end

  create_table "user_accomplishments", force: :cascade do |t|
    t.integer "accomplishment_type", null: false
    t.string "accomplishment_url"
    t.string "accomplishment_name", null: false
    t.text "accomplishment_description", null: false
    t.date "accomplishment_start_date"
    t.date "accomplishment_end_date"
    t.boolean "ongoing", default: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_accomplishments_on_user_id"
  end

  create_table "user_educations", force: :cascade do |t|
    t.string "institution_name", null: false
    t.string "degree", null: false
    t.integer "performance_type", default: 0
    t.decimal "performance", precision: 5, scale: 2
    t.date "start_date"
    t.date "end_date"
    t.boolean "currently_studying"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_educations_on_user_id"
  end

  create_table "user_skills", force: :cascade do |t|
    t.string "skill_name", null: false
    t.integer "skill_level", default: 0, null: false
    t.integer "user_id", null: false
    t.integer "user_work_experiences_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "skill_name"], name: "index_user_skills_on_user_id_and_skill_name", unique: true
    t.index ["user_id"], name: "index_user_skills_on_user_id"
    t.index ["user_work_experiences_id"], name: "index_user_skills_on_user_work_experiences_id"
  end

  create_table "user_work_experiences", force: :cascade do |t|
    t.string "company_name", null: false
    t.string "designation", null: false
    t.date "start_date"
    t.date "end_date"
    t.boolean "currently_working", default: false
    t.text "job_responsibilities"
    t.integer "employment_type", default: 0
    t.integer "user_id", null: false
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_user_work_experiences_on_company_id"
    t.index ["user_id"], name: "index_user_work_experiences_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.float "latitude"
    t.float "longitude"
    t.string "career_objective"
    t.date "dob"
    t.integer "gender", default: 0
    t.integer "account_status", default: 0
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "companies", "companies", column: "parent_company_id"
  add_foreign_key "recruiter_permissions_on_company", "companies"
  add_foreign_key "recruiter_permissions_on_company", "recruiters"
  add_foreign_key "recruitment_applies", "recruitments"
  add_foreign_key "recruitment_applies", "users"
  add_foreign_key "recruitments", "bkash_payments"
  add_foreign_key "recruitments", "companies"
  add_foreign_key "recruitments", "recruiters"
  add_foreign_key "user_accomplishments", "users"
  add_foreign_key "user_educations", "users"
  add_foreign_key "user_skills", "user_work_experiences", column: "user_work_experiences_id"
  add_foreign_key "user_skills", "users"
  add_foreign_key "user_work_experiences", "companies"
  add_foreign_key "user_work_experiences", "users"
end
