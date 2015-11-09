# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 1) do

  create_table "assets", force: :cascade do |t|
    t.string   "objectid",    limit: 255
    t.string   "symbol",      limit: 255
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.integer  "precision",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assets", ["objectid"], name: "index_assets_on_objectid", unique: true, using: :btree
  add_index "assets", ["symbol"], name: "index_assets_on_symbol", unique: true, using: :btree

  create_table "bts_accounts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.string   "objectid",   limit: 255
    t.string   "owner_key",  limit: 255
    t.string   "active_key", limit: 255
    t.string   "memo_key",   limit: 255
    t.string   "referrer",   limit: 255
    t.string   "refcode",    limit: 255
    t.string   "remote_ip",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bts_accounts", ["name"], name: "index_bts_accounts_on_key", unique: true, using: :btree
  add_index "bts_accounts", ["objectid"], name: "index_bts_accounts_on_objectid", unique: true, using: :btree
  add_index "bts_accounts", ["user_id"], name: "index_bts_accounts_on_user_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true, using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "referral_codes", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "asset_id",      limit: 4
    t.string   "code",          limit: 255
    t.string   "funded_by",     limit: 255
    t.integer  "amount",        limit: 8
    t.datetime "expires_at"
    t.string   "prerequisites", limit: 255
    t.datetime "redeemed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",         limit: 255
    t.string   "send_to",       limit: 255
    t.string   "login_hash",    limit: 255
  end

  add_index "referral_codes", ["asset_id"], name: "index_referral_codes_on_asset_id", using: :btree
  add_index "referral_codes", ["code"], name: "index_referral_codes_on_code", unique: true, using: :btree

  create_table "user_actions", force: :cascade do |t|
    t.integer  "widget_id",  limit: 4
    t.string   "uid",        limit: 255
    t.string   "action",     limit: 16
    t.string   "value",      limit: 255
    t.string   "ip",         limit: 48
    t.string   "user_agent", limit: 255
    t.string   "city",       limit: 255
    t.string   "state",      limit: 255
    t.string   "country",    limit: 255
    t.string   "refurl",     limit: 255
    t.string   "channel",    limit: 64
    t.string   "referrer",   limit: 64
    t.string   "refcode",    limit: 64
    t.string   "campaign",   limit: 64
    t.integer  "adgroupid",  limit: 4
    t.integer  "adid",       limit: 4
    t.integer  "keywordid",  limit: 4
    t.datetime "created_at"
  end

  add_index "user_actions", ["action"], name: "index_user_actions_on_action", using: :btree
  add_index "user_actions", ["campaign"], name: "index_user_actions_on_campaign", using: :btree
  add_index "user_actions", ["channel"], name: "index_user_actions_on_channel", using: :btree
  add_index "user_actions", ["referrer"], name: "index_user_actions_on_referrer", using: :btree
  add_index "user_actions", ["uid"], name: "index_user_actions_on_uid", using: :btree
  add_index "user_actions", ["widget_id"], name: "index_user_actions_on_widget_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                    limit: 255,   default: "",    null: false
    t.string   "email",                   limit: 255,   default: ""
    t.string   "encrypted_password",      limit: 255,   default: "",    null: false
    t.string   "reset_password_token",    limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",      limit: 255
    t.string   "last_sign_in_ip",         limit: 255
    t.string   "confirmation_token",      limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "is_admin",                              default: false
    t.string   "newsletter_subscription", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uid",                     limit: 32
    t.string   "unconfirmed_email",       limit: 255
    t.boolean  "newsletter_subscribed"
    t.text     "pending_intention",       limit: 65535
    t.boolean  "pending_codes"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  create_table "widgets", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.string   "allowed_domains", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "widgets", ["user_id"], name: "index_widgets_on_user_id", using: :btree

end
