class UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: %i[ edit update destroy block unblock ]

  def index
    @pagy, @users = pagy(:offset, User.order(:id))
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "User was successfully destroyed.", status: :see_other
  end

  def block
    @user.update!(blocked: true)
    redirect_to users_path, notice: "#{@user.name} was blocked."
  end

  def unblock
    @user.update!(blocked: false)
    redirect_to users_path, notice: "#{@user.name} was unblocked."
  end

  private

  def require_admin
    head :forbidden unless current_user&.admin?
  end

  def set_user
    @user = User.find(params.expect(:id))
  end

  def user_params
    attributes = params.expect(user: [ :name, :email, :time_zone, :password, :password_confirmation, :admin, :blocked ])
    attributes = attributes.except(:password, :password_confirmation) if attributes[:password].blank?
    attributes
  end
end
