class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :flickr_nsid
      t.string :flickr_username
      t.string :flickr_fullname
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
