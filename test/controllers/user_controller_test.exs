defmodule PxblogWeb.UserControllerTest do
  use PxblogWeb.ConnCase

  alias Pxblog.User
  import Pxblog.Factory

  @valid_create_attrs %{email: "test@test.com", username: "test", password: "test123", password_confirmation: "test123"}
  @valid_attrs %{email: "test@test.com", username: "test"}
  @invalid_attrs %{}

  setup do
    user_role     = insert(:role)
    nonadmin_user = insert(:user, role: user_role)

    admin_role = insert(:role, admin: true)
    admin_user = insert(:user, role: admin_role)

    {:ok, conn: build_conn(), admin_role: admin_role, user_role: user_role, nonadmin_user: nonadmin_user, admin_user: admin_user}
  end

  defp valid_create_attrs(role) do
    Map.put(@valid_create_attrs, :role_id, role.id)
  end

  defp login_user(conn, user) do
    post conn, session_path(conn, :create), user: %{email: user.email, password: user.password}
  end

  test "lists all entries on index", %{conn: conn, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Manage users"
  end

  @tag admin: true
  test "renders form for new resources", %{conn: conn, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  @tag admin: true
  test "redirects from new form when not admin", %{conn: conn, nonadmin_user: nonadmin_user} do
    conn = login_user(conn, nonadmin_user)
    conn = get conn, user_path(conn, :new)
    assert get_flash(conn, :error) == "You are not authorized to access this resource!"
    assert redirected_to(conn) == post_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "creates resource and redirects when data is valid", %{conn: conn, user_role: user_role, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = post conn, user_path(conn, :create), user: valid_create_attrs(user_role)
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "redirects from creating user when not admin", %{conn: conn, user_role: user_role, nonadmin_user: nonadmin_user} do
    conn = login_user(conn, nonadmin_user)
    conn = post conn, user_path(conn, :create), user: valid_create_attrs(user_role)
    assert get_flash(conn, :error) == "You are not authorized to access this resource!"
    assert redirected_to(conn) == post_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  @tag admin: true
  test "renders form for editing chosen resource when logged in as an admin", %{conn: conn, admin_user: admin_user, nonadmin_user: nonadmin_user} do
    conn = login_user(conn, admin_user)
    conn = get conn, user_path(conn, :edit, nonadmin_user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "redirects away from editing when logged in as a different user", %{conn: conn, nonadmin_user: nonadmin_user, admin_user: admin_user} do
    conn = login_user(conn, nonadmin_user)
    conn = get conn, user_path(conn, :edit, admin_user)
    assert get_flash(conn, :error) == "You are not authorized to access this resource!"
    assert redirected_to(conn) == post_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "updates chosen resource and redirects when data is valid when logged in as an admin", %{conn: conn, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = put conn, user_path(conn, :update, admin_user), user: @valid_create_attrs
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "does not update chosen resource when logged in as different user", %{conn: conn, nonadmin_user: nonadmin_user, admin_user: admin_user} do
    conn = login_user(conn, nonadmin_user)
    conn = put conn, user_path(conn, :update, admin_user), user: @valid_create_attrs
    assert get_flash(conn, :error) == "You are not authorized to access this resource!"
    assert redirected_to(conn) == post_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = put conn, user_path(conn, :update, admin_user), user: @invalid_attrs
    assert get_flash(conn, :info) == "User updated successfully."
    assert redirected_to(conn) == user_path(conn, :index)
  end

  @tag admin: true
  test "does not delete chosen resource when logged in as user", %{conn: conn, user_role: user_role} do
    user = insert(:user, role: user_role)
    conn =
      login_user(conn, user)
      |> delete(user_path(conn, :delete, user))
    assert get_flash(conn, :error) == "You are not authorized to access this resource!"
    assert redirected_to(conn) == post_path(conn, :index)
  end

  @tag admin: true
  test "deletes chosen resource when logged in as an admin", %{conn: conn, user_role: user_role, admin_user: admin_user} do
    user = insert(:user, role: user_role)
    conn =
      login_user(conn, admin_user)
      |> delete(user_path(conn, :delete, user))
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  @tag admin: true
  test "redirects away from deleting chosen resource when logged in as a different user", %{conn: conn, user_role: user_role, nonadmin_user: nonadmin_user} do
    user = insert(:user, role: user_role)
    conn =
      login_user(conn, nonadmin_user)
      |> delete(user_path(conn, :delete, user))
    assert get_flash(conn, :error) == "You are not authorized to access this resource!"
    assert redirected_to(conn) == post_path(conn, :index)
    assert conn.halted
  end
end
