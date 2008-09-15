class CustomizationsController < ApplicationController
  
  before_filter :login_required
  
  def new  
  end
  
  def create
    @updated = current_user.update_attributes(params[:user])
    if @updated
      flash[:notice] = "Your customizations were saved."
      redirect_to settings_path
    else
      render :action => :new
    end
  end
end
