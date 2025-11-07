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

ActiveRecord::Schema[8.0].define(version: 2025_11_06_155518) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "content_revisions", force: :cascade do |t|
    t.string "title"
    t.string "base_path"
    t.text "summary"
    t.json "contents", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.bigint "created_by_id", null: false
    t.index ["created_by_id"], name: "index_content_revisions_on_created_by_id"
  end

  create_table "documents", force: :cascade do |t|
    t.uuid "content_id", null: false
    t.datetime "first_published_at", precision: nil
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_documents_on_content_id", unique: true
    t.index ["created_by_id"], name: "index_documents_on_created_by_id"
  end

  create_table "edition_editors", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "edition_id", null: false
    t.bigint "user_id", null: false
    t.index ["edition_id", "user_id"], name: "index_edition_editors_on_edition_id_and_user_id", unique: true
    t.index ["edition_id"], name: "index_edition_editors_on_edition_id"
    t.index ["user_id"], name: "index_edition_editors_on_user_id"
  end

  create_table "editions", force: :cascade do |t|
    t.integer "number", null: false
    t.datetime "last_edited_at", precision: nil, null: false
    t.boolean "revision_synced", default: false, null: false
    t.datetime "published_at", precision: nil
    t.uuid "auth_bypass_id", null: false
    t.boolean "current", default: false, null: false
    t.boolean "live", default: false, null: false
    t.bigint "created_by_id", null: false
    t.bigint "last_edited_by_id", null: false
    t.bigint "document_id", null: false
    t.bigint "status_id", null: false
    t.bigint "revision_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_editions_on_created_by_id"
    t.index ["document_id"], name: "index_editions_on_document_id"
    t.index ["last_edited_by_id"], name: "index_editions_on_last_edited_by_id"
    t.index ["revision_id"], name: "index_editions_on_revision_id"
    t.index ["status_id"], name: "index_editions_on_status_id"
  end

  create_table "editions_revisions", id: false, force: :cascade do |t|
    t.bigint "edition_id", null: false
    t.bigint "revision_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["edition_id", "revision_id"], name: "index_editions_revisions_on_edition_id_and_revision_id"
    t.index ["edition_id"], name: "index_editions_revisions_on_edition_id"
    t.index ["revision_id"], name: "index_editions_revisions_on_revision_id"
  end

  create_table "metadata_revisions", force: :cascade do |t|
    t.string "update_type", null: false
    t.text "change_note"
    t.json "change_history", default: [], null: false
    t.string "document_type_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.bigint "created_by_id", null: false
    t.index ["created_by_id"], name: "index_metadata_revisions_on_created_by_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.integer "number", null: false
    t.datetime "created_at", precision: nil, null: false
    t.bigint "created_by_id", null: false
    t.bigint "document_id", null: false
    t.bigint "content_revision_id", null: false
    t.bigint "metadata_revision_id", null: false
    t.bigint "tags_revision_id", null: false
    t.bigint "preceded_by_id"
    t.index ["content_revision_id"], name: "index_revisions_on_content_revision_id"
    t.index ["created_by_id"], name: "index_revisions_on_created_by_id"
    t.index ["document_id"], name: "index_revisions_on_document_id"
    t.index ["metadata_revision_id"], name: "index_revisions_on_metadata_revision_id"
    t.index ["number", "document_id"], name: "index_revisions_on_number_and_document_id", unique: true
    t.index ["preceded_by_id"], name: "index_revisions_on_preceded_by_id"
    t.index ["tags_revision_id"], name: "index_revisions_on_tags_revision_id"
  end

  create_table "revisions_statuses", id: false, force: :cascade do |t|
    t.bigint "revision_id", null: false
    t.bigint "status_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["revision_id", "status_id"], name: "index_revisions_statuses_on_revision_id_and_status_id"
    t.index ["revision_id"], name: "index_revisions_statuses_on_revision_id"
    t.index ["status_id", "revision_id"], name: "index_revisions_statuses_on_status_id_and_revision_id"
    t.index ["status_id"], name: "index_revisions_statuses_on_status_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "state", null: false
    t.bigint "revision_at_creation_id", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "edition_id"
    t.index ["created_by_id"], name: "index_statuses_on_created_by_id"
    t.index ["edition_id"], name: "index_statuses_on_edition_id"
    t.index ["revision_at_creation_id"], name: "index_statuses_on_revision_at_creation_id"
  end

  create_table "tags_revisions", force: :cascade do |t|
    t.json "tags", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.bigint "created_by_id", null: false
    t.index ["created_by_id"], name: "index_tags_revisions_on_created_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.text "permissions"
    t.boolean "disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "content_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "documents", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "edition_editors", "editions", on_delete: :cascade
  add_foreign_key "edition_editors", "users", on_delete: :restrict
  add_foreign_key "editions", "documents", on_delete: :restrict
  add_foreign_key "editions", "revisions", on_delete: :restrict
  add_foreign_key "editions", "statuses", on_delete: :restrict
  add_foreign_key "editions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "editions", "users", column: "last_edited_by_id", on_delete: :restrict
  add_foreign_key "editions_revisions", "editions", on_delete: :cascade
  add_foreign_key "editions_revisions", "revisions", on_delete: :restrict
  add_foreign_key "metadata_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "revisions", "content_revisions", on_delete: :restrict
  add_foreign_key "revisions", "documents", on_delete: :restrict
  add_foreign_key "revisions", "metadata_revisions", on_delete: :restrict
  add_foreign_key "revisions", "revisions", column: "preceded_by_id", on_delete: :restrict
  add_foreign_key "revisions", "tags_revisions", on_delete: :restrict
  add_foreign_key "revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "revisions_statuses", "revisions", on_delete: :restrict
  add_foreign_key "revisions_statuses", "statuses", on_delete: :cascade
  add_foreign_key "statuses", "editions", on_delete: :cascade
  add_foreign_key "statuses", "revisions", column: "revision_at_creation_id", on_delete: :restrict
  add_foreign_key "statuses", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "tags_revisions", "users", column: "created_by_id", on_delete: :restrict
end
