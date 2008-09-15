class CreateRresets < ActiveRecord::Migration
  def self.up
    create_table :rresets do |t|
      t.integer :user_id
      t.integer :flickr_farm
      t.integer :flickr_photos
      t.integer :flickr_primary
      t.string  :flickr_title
      t.text    :flickr_description
      t.integer :flickr_server
      t.string  :flickr_secret
      t.string  :flickr_id
      t.timestamps
    end
  end

  def self.down
    drop_table :rresets
  end
end
