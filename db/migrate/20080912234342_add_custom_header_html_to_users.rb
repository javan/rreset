class AddCustomHeaderHtmlToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :custom_header_html, :text
  end

  def self.down
    remove_column :users, :custom_header_html
  end
end
