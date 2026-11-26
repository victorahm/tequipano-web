require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:two)
    @user = users(:one)
    log_in_as @admin
  end

  test "index lists all users for an admin" do
    get users_url

    assert_response :success
    assert_select "h1.app-main__title", "Users"
    assert_select "ul#users li.task-card", 2
    assert_select "ul#users li.task-card", text: /#{Regexp.escape(@user.name)}/
    assert_select "a[href=?]", new_user_path
  end

  test "new renders the admin user form" do
    get new_user_url

    assert_response :success
    assert_select "form[action=?]", users_path
    assert_select "input[name=?]", "user[name]"
    assert_select "input[name=?]", "user[email]"
    assert_select "input[name=?]", "user[time_zone]"
    assert_select "input[name=?][type=?]", "user[password]", "password"
    assert_select "input[name=?]", "user[blocked]"
  end

  test "admin creates an unblocked user" do
    assert_difference "User.count", 1 do
      post users_url, params: { user: { name: "New User", email: "new@example.com", time_zone: "UTC", password: "password", password_confirmation: "password" } }
    end

    created = User.find_by!(email: "new@example.com")
    assert_redirected_to users_url
    assert_not created.blocked?
    assert_not created.admin?

    delete logout_url
    post login_url, params: { email: created.email, password: "password" }
    assert_redirected_to root_url
  end

  test "admin can create another admin" do
    post users_url, params: { user: { name: "Helper", email: "helper@example.com", time_zone: "UTC", password: "password", password_confirmation: "password", admin: true } }

    assert User.find_by!(email: "helper@example.com").admin?
  end

  test "admin creates a blocked user when asked" do
    post users_url, params: { user: { name: "Pending", email: "pending@example.com", time_zone: "UTC", password: "password", password_confirmation: "password", blocked: true } }

    assert User.find_by!(email: "pending@example.com").blocked?
  end

  test "create with invalid data renders the form with errors" do
    assert_no_difference "User.count" do
      post users_url, params: { user: { name: "Invalid", email: "bad", time_zone: "UTC", password: "password", password_confirmation: "password" } }
    end

    assert_response :unprocessable_content
    assert_select ".form__group--error .form__error", minimum: 1
  end

  test "admin edits a user" do
    get edit_user_url(@user)

    assert_response :success
    assert_select "form[action=?]", user_path(@user)
    assert_select "input[name=?][value=?]", "user[name]", @user.name
  end

  test "admin updates a user" do
    patch user_url(@user), params: { user: { name: "Renamed", email: "renamed@example.com", time_zone: "Europe/Madrid", admin: true, blocked: true } }

    assert_redirected_to users_url
    @user.reload
    assert_equal "Renamed", @user.name
    assert_equal "renamed@example.com", @user.email
    assert_equal "Europe/Madrid", @user.time_zone
    assert @user.admin?
    assert @user.blocked?
  end

  test "admin update leaves the password unchanged when it is blank" do
    digest = @user.password_digest

    patch user_url(@user), params: { user: { name: @user.name, email: @user.email, time_zone: @user.time_zone, password: "", password_confirmation: "" } }

    assert_equal digest, @user.reload.password_digest
  end

  test "admin blocks and unblocks a user" do
    patch block_user_url(@user)

    assert_redirected_to users_url
    assert @user.reload.blocked?

    patch unblock_user_url(@user)

    assert_redirected_to users_url
    assert_not @user.reload.blocked?
  end

  test "admin deletes a user" do
    assert_difference "User.count", -1 do
      delete user_url(@user)
    end

    assert_redirected_to users_url
    assert_not User.exists?(@user.id)
  end

  test "non-admin users are forbidden from managing users" do
    log_in_as @user

    get users_url
    assert_response :forbidden

    get new_user_url
    assert_response :forbidden

    post users_url, params: { user: { name: "Nope", email: "nope@example.com", time_zone: "UTC", password: "password", password_confirmation: "password" } }
    assert_response :forbidden
    assert_not User.exists?(email: "nope@example.com")

    get edit_user_url(@admin)
    assert_response :forbidden

    patch user_url(@admin), params: { user: { name: "Hijacked" } }
    assert_response :forbidden
    assert_not_equal "Hijacked", @admin.reload.name

    patch block_user_url(@admin)
    assert_response :forbidden
    assert_not @admin.reload.blocked?

    patch unblock_user_url(@admin)
    assert_response :forbidden

    assert_no_difference "User.count" do
      delete user_url(@admin)
    end
    assert_response :forbidden
  end
end
