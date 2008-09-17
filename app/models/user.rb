# == Schema Information
# Schema version: 20080909233215
#
# Table name: users
#
#  id              :integer(11)     not null, primary key
#  flickr_nsid     :string(255)     
#  flickr_username :string(255)     
#  flickr_fullname :string(255)     
#  created_at      :datetime        
#  updated_at      :datetime        
#

class User < ActiveRecord::Base
  has_many :rresets, :dependent => :destroy
  
  attr_readonly :flickr_nsid
  validates_presence_of :flickr_nsid, :flickr_username
  validates_uniqueness_of :flickr_nsid, :flickr_username
  
  def display_name
    if flickr_fullname.blank?
      flickr_username
    else
      flickr_fullname
    end
  end
end
