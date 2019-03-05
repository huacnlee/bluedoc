# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_05_023555) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "actions", id: :serial, force: :cascade do |t|
    t.string "action_type", limit: 20, null: false
    t.string "action_option", limit: 20
    t.string "target_type", limit: 20
    t.integer "target_id"
    t.string "user_type", limit: 20
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type", "target_type", "target_id", "user_type", "user_id"], name: "uk_action_target_user", unique: true
    t.index ["target_type", "target_id", "action_type"], name: "index_actions_on_target_type_and_target_id_and_action_type"
    t.index ["user_type", "user_id", "action_type"], name: "index_actions_on_user_type_and_user_id_and_action_type"
  end

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "action", limit: 20, null: false
    t.integer "user_id"
    t.integer "actor_id", null: false
    t.integer "group_id"
    t.integer "repository_id"
    t.string "target_type", limit: 20, null: false
    t.integer "target_id", null: false
    t.text "meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_activities_on_actor_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "authorizations", force: :cascade do |t|
    t.string "provider", limit: 50, null: false
    t.string "uid", limit: 1000, null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["provider", "uid"], name: "index_authorizations_on_provider_and_uid"
    t.index ["user_id"], name: "index_authorizations_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "commentable_type", limit: 20
    t.integer "commentable_id"
    t.integer "parent_id"
    t.text "body"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "format", limit: 20, default: "markdown", null: false
    t.text "body_sml"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["deleted_at"], name: "index_comments_on_deleted_at"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "docs", force: :cascade do |t|
    t.string "title", null: false
    t.string "draft_title"
    t.string "slug", limit: 200, null: false
    t.integer "repository_id"
    t.integer "creator_id"
    t.integer "last_editor_id"
    t.integer "comments_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.datetime "body_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "editor_ids", default: [], null: false, array: true
    t.datetime "deleted_at"
    t.string "deleted_slug"
    t.string "format", limit: 20, default: "markdown"
    t.integer "reads_count", default: 0, null: false
    t.index "repository_id, lower((slug)::text)", name: "index_on_repository_and_slug", unique: true
    t.index ["deleted_at"], name: "index_docs_on_deleted_at"
    t.index ["repository_id"], name: "index_docs_on_repository_id", where: "(deleted_at IS NULL)"
  end

  create_table "exception_tracks", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "subject_type", limit: 50, null: false
    t.integer "subject_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_members_on_deleted_at"
    t.index ["subject_type", "subject_id"], name: "index_members_on_subject_type_and_subject_id", where: "(deleted_at IS NULL)"
    t.index ["user_id", "subject_type", "subject_id"], name: "index_user_subject", unique: true
    t.index ["user_id"], name: "index_members_on_user_id", where: "(deleted_at IS NULL)"
  end

  create_table "mentions", force: :cascade do |t|
    t.string "mentionable_type", limit: 20
    t.integer "mentionable_id"
    t.integer "user_ids", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mentionable_type", "mentionable_id"], name: "index_mentions_on_mentionable_type_and_mentionable_id", unique: true
  end

  create_table "notes", force: :cascade do |t|
    t.string "slug", limit: 200
    t.string "title", null: false
    t.string "description", limit: 500
    t.bigint "user_id", null: false
    t.integer "reads_count", default: 0, null: false
    t.integer "stars_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "privacy", default: 1, null: false
    t.string "format", limit: 20, default: "markdown", null: false
    t.datetime "body_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deleted_slug", limit: 200
    t.index ["user_id", "body_updated_at"], name: "index_notes_on_user_id_and_body_updated_at"
    t.index ["user_id", "deleted_at"], name: "index_notes_on_user_id_and_deleted_at"
    t.index ["user_id", "slug"], name: "index_notes_on_user_id_and_slug", unique: true
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "actor_id"
    t.string "notify_type", null: false
    t.string "target_type"
    t.integer "target_id"
    t.integer "group_id"
    t.string "repository_id"
    t.text "meta"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_notifications_on_group_id"
    t.index ["repository_id"], name: "index_notifications_on_repository_id"
    t.index ["target_type", "target_id"], name: "index_notifications_on_target_type_and_target_id"
    t.index ["user_id", "notify_type"], name: "index_notifications_on_user_id_and_notify_type"
  end

  create_table "reactions", force: :cascade do |t|
    t.string "subject_type", limit: 20, null: false
    t.integer "subject_id", null: false
    t.string "name", limit: 100
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_type", "subject_id", "user_id", "name"], name: "subject_user_id_name", unique: true
    t.index ["user_id", "name"], name: "index_reactions_on_user_id_and_name"
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.string "slug", limit: 128, null: false
    t.string "name", null: false
    t.bigint "user_id"
    t.integer "creator_id"
    t.string "description"
    t.integer "privacy", default: 1, null: false
    t.integer "watches_count", default: 0, null: false
    t.integer "stars_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "preferences"
    t.integer "members_count", default: 0, null: false
    t.integer "editor_ids", default: [], null: false, array: true
    t.datetime "deleted_at"
    t.string "deleted_slug"
    t.index "user_id, lower((slug)::text)", name: "index_on_user_and_slug", unique: true
    t.index ["deleted_at"], name: "index_repositories_on_deleted_at"
    t.index ["user_id"], name: "index_repositories_on_user_id", where: "(deleted_at IS NULL)"
  end

  create_table "repository_sources", force: :cascade do |t|
    t.bigint "repository_id"
    t.string "provider", limit: 20
    t.string "url"
    t.string "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.integer "retries_count", default: 0, null: false
    t.text "message"
    t.index ["repository_id"], name: "index_repository_sources_on_repository_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "shares", force: :cascade do |t|
    t.string "slug", limit: 128
    t.string "shareable_type", limit: 20
    t.integer "shareable_id"
    t.integer "repository_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id"], name: "index_shares_on_repository_id"
    t.index ["shareable_type", "shareable_id"], name: "index_shares_on_shareable_type_and_shareable_id", unique: true
    t.index ["slug"], name: "index_shares_on_slug", unique: true
    t.index ["user_id"], name: "index_shares_on_user_id"
  end

  create_table "user_actives", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "subject_type", limit: 20, null: false
    t.integer "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["updated_at"], name: "index_user_actives_on_updated_at"
    t.index ["user_id", "subject_type", "subject_id"], name: "index_user_actives_on_user_id_and_subject_type_and_subject_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "type", limit: 20, default: "User", null: false
    t.string "slug", limit: 128, null: false
    t.string "name", limit: 64, default: "", null: false
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "members_count", default: 0, null: false
    t.string "url"
    t.string "description"
    t.string "location", limit: 50
    t.integer "followers_count", default: 0, null: false
    t.integer "following_count", default: 0, null: false
    t.datetime "deleted_at"
    t.string "deleted_slug"
    t.string "locale"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index "lower((slug)::text)", name: "index_on_slug", unique: true
    t.index "type, lower((email)::text)", name: "index_on_type_and_email"
    t.index "type, lower((email)::text)", name: "uk_on_type_and_email", unique: true, where: "((COALESCE(email, ''::character varying))::text <> ''::text)"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "type", limit: 20
    t.string "subject_type", limit: 20
    t.integer "subject_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "format", limit: 20, default: "markdown"
    t.index ["subject_type", "subject_id"], name: "index_versions_on_subject_type_and_subject_id"
    t.index ["type"], name: "index_versions_on_type"
    t.index ["user_id"], name: "index_versions_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "shares", "users"
end
