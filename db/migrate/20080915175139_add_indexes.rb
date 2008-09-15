class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :rresets, :user_id
    add_index :rresets, :flickr_id
    add_index :users, :flickr_nsid
  end

  def self.down
    remove_index :rresets, :user_id
    remove_index :rresets, :flickr_id
    mind
    remove_index :users, :flickr_nsid
  end
end
