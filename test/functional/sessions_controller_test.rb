require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  context 'New session request with a frob param' do
    setup do
      @frob = 'abc123'
      @user = Factory.build(:user)
      Flickr.expects(:auth_get_token).at_least_once.with(@frob).returns(frob_response_hash(@user)) 
      get :new, :frob => @frob
    end
    
    should_assign_to :flickr
    should_change "User.count", :by => 1
    should_redirect_to "settings_path"
    
    should 'set the session' do
      assert_equal @user.flickr_nsid, session[:flickr][:nsid]
      assert_equal frob_response_hash(@user)[:auth][:token], session[:flickr][:auth_token]
      assert_instance_of Time, session[:flickr][:last_auth]
    end
    
    context 'for the second time as the same user' do
      setup { get :new, :frob => @frob }
      should_not_change "User.count"
    end
  end
  
  context 'New session that fails to create or find a user' do
    setup do
      @frob = 'abc123'
      @user = Factory.build(:user, :flickr_nsid => nil)
      Flickr.expects(:auth_get_token).at_least_once.with(@frob).returns(frob_response_hash(@user))
      get :new, :frob => @frob
    end
    
    should_not_change "User.count"
    should_redirect_to "root_path"
    
    should 'clear the flickr data in the session' do
      assert_nil session[:flickr]
    end
  end
  
  context 'New session request with no frob param' do
    setup { get :new }
    should_redirect_to 'root_path'
  end
  
  context 'Logging out' do
    setup { get :destroy }
    should_redirect_to 'root_path'
    
    should 'clear the flickr data in the session' do
      assert_nil session[:flickr]
    end
  end
  
private

  def frob_response_hash(user = nil, options = {})
    user ||= Factory.build(:user)
    {
      :auth => {
        :token => '3485976234875623',
        :user => {
          :nsid => user.flickr_nsid,
          :username => user.flickr_username,
          :fullname => user.flickr_fullname
        }
      }
    }.update(options)
  end
end
