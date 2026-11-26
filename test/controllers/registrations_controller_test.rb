require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  SIGNUP_ATTRIBUTES = {
    name: "Visitor",
    email: "visitor@example.com",
    time_zone: "UTC",
    password: "password",
    password_confirmation: "password"
  }.freeze

  test "signup page renders the registration form" do
    get signup_url

    assert_response :success
    assert_select "h1.app-main__title", "Sign up"
    assert_select "form[action=?]", signup_path
    assert_select "input[name=?]", "user[name]"
    assert_select "input[name=?]", "user[email]"
    assert_select "input[name=?]", "user[time_zone]"
    assert_select "input[name=?][type=?]", "user[password]", "password"
  end

  test "signup creates a blocked, non-admin account" do
    assert_difference "User.count", 1 do
      post signup_url, params: { user: SIGNUP_ATTRIBUTES }
    end

    user = User.find_by!(email: SIGNUP_ATTRIBUTES[:email])
    assert user.blocked?
    assert_not user.admin?
    assert_redirected_to login_url

    post login_url, params: { email: user.email, password: SIGNUP_ATTRIBUTES[:password] }
    assert_response :unprocessable_content
  end

  test "signup cannot grant admin or bypass blocking" do
    post signup_url, params: { user: SIGNUP_ATTRIBUTES.merge(admin: true, blocked: false) }

    user = User.find_by!(email: SIGNUP_ATTRIBUTES[:email])
    assert_not user.admin?
    assert user.blocked?
  end

  test "signup with invalid data renders the form with errors" do
    assert_no_difference "User.count" do
      post signup_url, params: { user: SIGNUP_ATTRIBUTES.merge(email: "not-an-email", password_confirmation: "mismatch") }
    end

    assert_response :unprocessable_content
    assert_select ".form__group--error .form__error", minimum: 1
  end

  test "signed-in users are redirected away from signup" do
    log_in_as users(:one)

    get signup_url

    assert_redirected_to root_url
  end
end
