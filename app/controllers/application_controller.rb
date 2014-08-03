class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
#  protect_from_forgery with: :null_session
  
  before_action :require_login, :except => [:login, :do_login]
  
  private
 
  def require_login
    session[:iniciado]=true

    if !(session[:logged] == "SI")
      render :action => 'redirect_login', :layout=>'redirect_login'
    end

  end
  
end
