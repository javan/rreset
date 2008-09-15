class SessionsController < ApplicationController
  
  # Users get directed here after authenticating with Flickr.
  # It's not the most RESTful thing in the world to perform
  # a create here. Oh well!
  def new
    if params[:frob]
      @flickr = Flickr.auth_get_token(params[:frob])
      user = User.find_or_create_by_flickr_nsid(
       :flickr_username => @flickr[:auth][:user][:username],
       :flickr_nsid     => @flickr[:auth][:user][:nsid],
       :flickr_fullname => @flickr[:auth][:user][:fullname]
      )
      if user.valid?
        # A user was found or created
        session[:flickr] = {
         :nsid       => @flickr[:auth][:user][:nsid],
         :auth_token => @flickr[:auth][:token],
         :last_auth  => Time.now
        }
        flash[:notice] = 'Welcome!'
        redirect_to settings_path
      else
        # User failed to create for some reason
        session[:flickr] = nil
        flash[:error] = "We're sorry, something went wrong."
        redirect_to root_path
      end
    else
      # If there was no frob parameter
      flash[:error] = "Please click the Log in link to begin."
      redirect_to root_path
    end
  end
  
  def destroy
    session[:flickr] = nil
    flash[:notice] = "You have been logged out."
    redirect_to root_path    
  end

end
