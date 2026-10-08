require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    tag = Tag.new(name: "work", color: "#0000FF")
    assert tag.valid?
  end

  test "should require name" do
    tag = Tag.new(color: "#0000FF")
    assert_not tag.valid?
  end
end
