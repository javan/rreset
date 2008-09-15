class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  
  helper :all 

  protect_from_forgery 
  
  rescue_from Flickr::ConnectionError,
              ActiveRecord::RecordNotFound, :with => :failure
  
  def current_user
    return false unless session[:flickr] && session[:flickr][:nsid]
    @current_user ||= (User.find_by_flickr_nsid(session[:flickr][:nsid]) || false)
  end
  helper_method :current_user
  
  def logged_in?
    current_user != false
  end
  helper_method :logged_in?
  
  def login_required
    return if logged_in?
    flash[:error] = 'You must log in before you can do that.'
    redirect_to root_path
  end
  

  def failure(exception)
    case exception
      when Flickr::ConnectionError
        render :text => "<h1 class='notice' style='margin: 30px'>Sorry, we had some trouble communicating with Flickr. Please refresh and try again.</h1>", :layout => true, :status => 500
      when ActiveRecord::RecordNotFound
        render :text => "<h1 class='notice' style='margin: 30px'>Sorry, we couldn't find what you're looking for.<h1>", :layout => true, :status => 404
    end
  end
end
