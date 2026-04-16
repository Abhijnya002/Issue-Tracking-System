require_relative "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "sign in page loads" do
    visit new_session_url
    assert_text "Sign in"
  end
end
