require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context 'A User instance in general' do
    setup do
      @user = Factory.create(:user)
    end
    
    should_change "User.count", :by => 1
    should_require_attributes :flickr_nsid, :flickr_username
    should_require_unique_attributes :flickr_nsid, :flickr_username
    should_have_readonly_attributes :flickr_nsid
    should_have_many :rresets
  end
end
