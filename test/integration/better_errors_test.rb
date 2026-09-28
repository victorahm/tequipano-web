require "test_helper"

class BetterErrorsTest < ActiveSupport::TestCase
  test "is installed for the development group only" do
    dependency = Bundler.definition.dependencies.find { |gem| gem.name == "better_errors" }

    assert dependency, "expected better_errors to be declared in the Gemfile"
    assert_equal [ :development ], dependency.groups
  end

  test "is not loaded in the test environment" do
    refute_includes Bundler.require(*Rails.groups).map(&:name), "better_errors"
  end
end
