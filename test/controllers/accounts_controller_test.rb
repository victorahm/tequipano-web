require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    log_in_as @user
  end

  test "account page shows the signed-in user's personal data" do
    get account_url

    assert_response :success
    assert_select "h1.app-main__title", "My account"
    assert_select "main.app-main", text: /#{Regexp.escape(@user.name)}/
    assert_select "main.app-main", text: /#{Regexp.escape(@user.email)}/
    assert_select "a[href=?]", edit_account_path
  end

  test "edit page renders the account form" do
    get edit_account_url

    assert_response :success
    assert_select "form[action=?]", account_path
    assert_select "input[name=?][value=?]", "user[name]", @user.name
    assert_select "input[name=?][value=?]", "user[email]", @user.email
    assert_select "input[name=?][type=?]", "user[password]", "password"
  end

  test "account update changes personal data" do
    patch account_url, params: { user: { name: "New Name", email: "new@example.com", time_zone: "UTC", password: "", password_confirmation: "" } }

    assert_redirected_to account_url
    @user.reload
    assert_equal "New Name", @user.name
    assert_equal "new@example.com", @user.email
    assert_equal "UTC", @user.time_zone
  end

  test "account update changes the password" do
    patch account_url, params: { user: { name: @user.name, email: @user.email, time_zone: @user.time_zone, password: "new-password", password_confirmation: "new-password" } }

    assert_redirected_to account_url
    assert @user.reload.authenticate("new-password")

    delete logout_url
    post login_url, params: { email: @user.email, password: "new-password" }
    assert_redirected_to root_url
  end

  test "account update with a blank password keeps the current password" do
    digest = @user.password_digest

    patch account_url, params: { user: { name: @user.name, email: @user.email, time_zone: @user.time_zone, password: "", password_confirmation: "something" } }

    assert_equal digest, @user.reload.password_digest
  end

  test "account update with invalid data renders the form with errors" do
    patch account_url, params: { user: { name: "", email: "invalid", time_zone: @user.time_zone, password: "", password_confirmation: "" } }

    assert_response :unprocessable_content
    assert_select ".form__group--error .form__error", minimum: 1
    assert_equal "Alice", @user.reload.name
  end

  test "account cannot take another user's email" do
    other = users(:two)

    patch account_url, params: { user: { name: @user.name, email: other.email, time_zone: @user.time_zone, password: "", password_confirmation: "" } }

    assert_response :unprocessable_content
    assert_equal @user.email, @user.reload.email
  end
end
