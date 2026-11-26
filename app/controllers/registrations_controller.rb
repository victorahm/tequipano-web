class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: %i[ new create ]
  before_action :redirect_if_logged_in, only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(signup_params)
    @user.blocked = true
    @user.admin = false

    if @user.save
      redirect_to login_path, notice: "Account created. An administrator must unblock it before you can log in."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def signup_params
    params.expect(user: [ :name, :email, :time_zone, :password, :password_confirmation ])
  end
end
