module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?
    before_action :require_login
  end

  def current_user
    return @current_user if defined?(@current_user)

    user = User.find_by(id: session[:user_id]) if session[:user_id].present?
    @current_user = user && !user.blocked? ? user : nil
  end

  def logged_in?
    current_user.present?
  end

  private

  def require_login
    return if logged_in?

    reset_session if session[:user_id].present?
    redirect_to login_path, alert: "Please log in to continue."
  end

  def redirect_if_logged_in
    redirect_to root_path, notice: "You are already logged in." if logged_in?
  end
end
