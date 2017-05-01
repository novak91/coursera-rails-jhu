class SessionsController < ApplicationController
  skip_before_action :ensure_login, only: [:new, :create]
  def new
  end

  def create
    user = User.find_by(username: params[:user][:username])
    password = params[:user][:password]
    
    if user && user.authenticate(password)
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in successfully"
    else
      redirect_to login_path, alert: "Unsuccessful login :("
    end
  end

  def destroy
    reset_session
    redirect_to login_path, alert: "Logged out successfully"
  end
end
