class UsersController < ApplicationController
  
  before_filter :login_required
  
  # The only thing to do here is destroy since 
  # the creation of users happens in the sessions controller
  
  def destroy
    if current_user.destroy
      session[:flickr] = nil
      flash[:notice] = 'Sorry to see you go. Come back any time.'
    else
      flash[:error] = 'Oops, something went wrong. Please try again, and feel free to contact support.'
    end
    
    redirect_to root_path
  end
end