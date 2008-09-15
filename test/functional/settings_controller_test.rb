require 'test_helper'

class SettingsControllerTest < ActionController::TestCase

  should_require_authentication 'get :index'
  
  context 'A logged in user with no rresets' do
    setup do
      @user = Factory.create(:user)
      login_as(@user)
      mock_flickr_call(:flickr_photosets_get_list)
      get :index
    end
    
    should_assign_to :rresets, :photosets
    should_render_template :index
    
    should 'not have any shared photosets' do
      assert_select 'input[value="stop sharing"]', false
    end
    
  end
end
