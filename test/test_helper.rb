ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

require 'factories'

class Test::Unit::TestCase
  
  def login_as(user)
    @request.session[:flickr] = {
     :nsid       => user.flickr_nsid,
     :auth_token => 'some made up token',
     :last_auth  => Time.now
    }
  end
  
  def mock_flickr_call(call, times = 1)
    Flickr.any_instance.expects(:get).times(times).with(anything).returns(File.read("#{RAILS_ROOT}/test/feeds/#{call}.xml"))
  end
  
  def self.should_require_authentication(expression)
    context "Ensuring authentication redirection for #{expression}" do
      setup { lambda { eval(expression) }.bind(self).call }
      should_set_the_flash_to /log in/i
      should_redirect_to 'root_path'
    end
  end
  
  def self.should_send_back_javascript
    should 'send back javascript' do
      assert_match /text\/javascript/, @response.headers['type']
    end
  end
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
end
