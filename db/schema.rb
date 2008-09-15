# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080915175139) do

  create_table "rresets", :force => true do |t|
    t.integer  "user_id",                :limit => 11
    t.string   "flickr_farm"
    t.integer  "flickr_photos",          :limit => 11
    t.string   "flickr_primary"
    t.string   "flickr_title"
    t.text     "flickr_description"
    t.string   "flickr_server"
    t.string   "flickr_secret"
    t.string   "flickr_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "newest_flickr_photo_id"
  end

  add_index "rresets", ["user_id"], :name => "index_rresets_on_user_id"
  add_index "rresets", ["flickr_id"], :name => "index_rresets_on_flickr_id"

  create_table "users", :force => true do |t|
    t.string   "flickr_nsid"
    t.string   "flickr_username"
    t.string   "flickr_fullname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "custom_header_html"
  end

  add_index "users", ["flickr_nsid"], :name => "index_users_on_flickr_nsid"

end
