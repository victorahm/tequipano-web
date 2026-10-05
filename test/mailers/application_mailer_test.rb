require "test_helper"

class SlimMailer < ApplicationMailer
  default from: "from@example.com"

  def ping
    mail(to: "to@example.com", subject: "Ping") do |format|
      format.html { render inline: "<p>Hi</p>", layout: "mailer" }
      format.text { render inline: "Hi", layout: "mailer" }
    end
  end
end

class ApplicationMailerTest < ActionMailer::TestCase
  test "renders the html mailer layout as slim" do
    body = SlimMailer.ping.html_part.body.to_s

    assert_includes body, "<!DOCTYPE html>"
    assert_includes body, "<p>Hi</p>"
    assert_includes body, %(http-equiv="Content-Type")
    assert_includes body, %(charset=utf-8)
  end

  test "renders the text mailer layout as slim" do
    assert_equal "Hi", SlimMailer.ping.text_part.body.to_s.strip
  end
end
