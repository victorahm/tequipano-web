require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @other_user.update!(blocked: true)
  end

  test "login page renders the credentials form" do
    get login_url

    assert_response :success
    assert_select "h1.app-main__title", "Log in"
    assert_select "form[action=?]", login_path
    assert_select "input[name=?]", "email"
    assert_select "input[name=?][type=?]", "password", "password"
  end

  test "logs in an unblocked user with the right credentials" do
    post login_url, params: { email: @user.email, password: "password" }

    assert_redirected_to root_url
    follow_redirect!
    assert_select ".side-menu__footer .user-profile__name", @user.name
    assert_select "form[action=?]", logout_path
  end

  test "wrong password does not log the user in" do
    post login_url, params: { email: @user.email, password: "wrong-password" }

    assert_response :unprocessable_content
    assert_select ".side-menu__footer .user-profile__name", count: 0
  end

  test "unknown email does not log the user in" do
    post login_url, params: { email: "nobody@example.com", password: "password" }

    assert_response :unprocessable_content
  end

  test "blocked account cannot log in" do
    assert_no_difference "User.count" do
      post login_url, params: { email: @other_user.email, password: "password" }
    end

    assert_response :unprocessable_content
    assert_select ".side-menu__footer .user-profile__name", count: 0
  end

  test "blocking a signed-in user terminates the session on the next request" do
    post login_url, params: { email: @user.email, password: "password" }
    @user.update!(blocked: true)

    get lists_url

    assert_redirected_to login_url
  end

  test "logout terminates the session" do
    log_in_as @user

    delete logout_url

    assert_redirected_to root_url
    get lists_url
    assert_redirected_to login_url
  end

  test "lists require login" do
    get lists_url

    assert_redirected_to login_url
  end

  test "tasks require login" do
    get tasks_url

    assert_redirected_to login_url
  end

  test "account requires login" do
    get account_url

    assert_redirected_to login_url
  end

  test "users management requires login" do
    get users_url

    assert_redirected_to login_url
  end
end
