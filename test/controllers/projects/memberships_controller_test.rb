require "test_helper"

class Projects::MembershipsControllerTest < ActionDispatch::IntegrationTest
  test "admin can open team page and add an existing user" do
    sign_in_as(users(:one))
    project = projects(:one)

    get project_memberships_path(project)
    assert_response :success

    assert_difference -> { project.project_memberships.count }, +1 do
      post project_memberships_path(project), params: {
        membership: { email_address: users(:three).email_address, role: "member" }
      }
    end
    assert_redirected_to project_memberships_path(project)

    sign_out
    sign_in_as(users(:three))

    get root_path
    assert_response :success
    assert_match(/Alpha project/, @response.body)
  end

  test "viewer cannot manage team" do
    sign_in_as(users(:two))
    project = projects(:one)

    get project_memberships_path(project)
    assert_redirected_to project_path(project)

    post project_memberships_path(project), params: {
      membership: { email_address: "nobody@example.com", role: "member" }
    }
    assert_redirected_to project_path(project)
  end
end
