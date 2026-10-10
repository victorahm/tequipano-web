module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
    before_action :require_current_user
  end

  def current_user
    @current_user ||= User.order(:id).first
  end

  private

  def require_current_user
    return if current_user

    raise "No users found. Run bin/rails db:seed to create the temporal current user."
  end
end
