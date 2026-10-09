require "test_helper"

class WelcomePageTest < ActionDispatch::IntegrationTest
  test "renders the welcome page at the root path" do
    get root_url

    assert_response :success
    assert_select "div.app-shell"
    assert_select "aside.app-sidebar nav.side-menu"
    assert_select "main.app-main", 1
  end

  test "showcases the main components" do
    get root_url

    assert_select "section form.form"
    assert_select "form.form .form__input", minimum: 1
    assert_select "form.form .btn--primary"

    assert_select "section .task-list"
    assert_select ".task-list .task-card", minimum: 1
    assert_select ".task-card .task-card__handle", minimum: 1
    assert_select ".badge--doing"

    assert_select ".user-profile--card"
  end
end
