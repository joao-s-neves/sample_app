require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "only show activated users in index" do
    log_in_as @non_admin
    @user = users(:lana)
    get users_path
    assert_match @user.name, response.body
    @user.toggle!(:activated)
    get users_path
    assert_no_match @user.name, response.body
    @user.toggle!(:activated)
  end
  
  test "should redirect show when user not activated" do
    log_in_as(@admin)
    user = @non_admin
    get user_path(user)
    assert_template 'users/show'
    user.toggle!(:activated)
    get user_path(user)
    assert_redirected_to root_url
    user.toggle!(:activated)
  end
end