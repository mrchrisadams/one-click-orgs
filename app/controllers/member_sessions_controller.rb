class MemberSessionsController < ApplicationController
  skip_before_filter :ensure_authenticated
  skip_before_filter :ensure_member_active
  #skip_before_filter :ensure_organisation_active
  skip_before_filter :ensure_member_inducted
  skip_before_filter :prepare_notifications
  
  def new
    @page_title = "Login"
    redirect_to root_path if current_user
  end
  
  def create
    self.current_user = co.members.authenticate(params[:email], params[:password])
    if current_user
      current_user.update_attribute(:last_logged_in_at, Time.now.utc)
      
      flash[:notice] = "Welcome back, #{current_user.name}!"
      redirect_back_or_default
    else
      flash.now[:error] = "The email address or password entered were incorrect"
      render(:action => :new)
    end
  end
  
  def destroy
    reset_session
    flash[:notice] = "Logged Out"
    redirect_to(root_path)
  end
end
