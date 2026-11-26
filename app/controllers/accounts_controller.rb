class AccountsController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(account_params)
      redirect_to account_path, notice: "Account was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = current_user
  end

  def account_params
    attributes = params.expect(user: [ :name, :email, :time_zone, :password, :password_confirmation ])
    attributes = attributes.except(:password, :password_confirmation) if attributes[:password].blank?
    attributes
  end
end
