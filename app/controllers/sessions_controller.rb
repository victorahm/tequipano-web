class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[ new create destroy ]
  before_action :redirect_if_logged_in, only: %i[ new create ]

  def new
  end

  def create
    user = User.find_by(email: credentials[:email].to_s.strip.downcase)

    if user&.authenticate(credentials[:password].to_s) && !user.blocked?
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = if user&.blocked?
        "Your account is blocked. Contact an administrator."
      else
        "Invalid email or password."
      end
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out successfully."
  end

  private

  def credentials
    params.permit(:email, :password)
  end
end
