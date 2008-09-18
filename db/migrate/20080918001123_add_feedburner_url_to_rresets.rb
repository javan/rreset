class AddFeedburnerUrlToRresets < ActiveRecord::Migration
  def self.up
    add_column :rresets, :feedburner_url, :string
  end

  def self.down
    remove_column :rresets, :feedburner_url
  end
end
