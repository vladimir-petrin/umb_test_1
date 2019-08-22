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

ActiveRecord::Schema.define(version: 2019_08_21_194254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.inet "author_ip", null: false
    t.integer "avg_score", limit: 2
    t.index ["author_ip"], name: "index_posts_on_author_ip"
    t.index ["avg_score"], name: "index_posts_on_avg_score"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "scores", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "value", limit: 2, null: false
    t.index ["post_id"], name: "index_scores_on_post_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login", null: false
    t.index ["login"], name: "index_users_on_login", unique: true
  end

  add_foreign_key "posts", "users"
  add_foreign_key "scores", "posts"
end
