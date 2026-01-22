<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Edit Profile | iVote</title>
        <link rel="stylesheet" href="style.css">
    </head>

    <body class="login-body"> <!-- Added login-body class -->

        <%
            if (session == null || session.getAttribute("user_id") == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            int userId = (Integer) session.getAttribute("user_id");

            String userName = "";
            String email = "";
            String role = "";
            String faculty = "";
            String message = "";

            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                conn = DriverManager.getConnection(
                        "jdbc:derby://localhost:1527/iVoteDB", "app", "app");

                String sql = "SELECT USER_NAME, EMAIL, ROLE, FACULTY FROM USERS WHERE USER_ID=?";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, userId);
                rs = stmt.executeQuery();

                if (rs.next()) {
                    userName = rs.getString("USER_NAME");
                    email = rs.getString("EMAIL");
                    role = rs.getString("ROLE");
                    faculty = rs.getString("FACULTY");
                }
            } catch (Exception e) {
                message = "Error loading profile.";
            } finally {
                if (rs != null) {
                    rs.close();
                }
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            }

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String newUserName = request.getParameter("userName");
                String newRole = request.getParameter("role");
                String newFaculty = request.getParameter("faculty");
                String newPassword = request.getParameter("password");

                try {
                    conn = DriverManager.getConnection(
                            "jdbc:derby://localhost:1527/iVoteDB", "app", "app");

                    String updateSql = "UPDATE USERS SET USER_NAME=?, ROLE=?, FACULTY=?"
                            + (newPassword != null && !newPassword.isEmpty() ? ", PASSWORD=?" : "")
                            + " WHERE USER_ID=?";

                    stmt = conn.prepareStatement(updateSql);

                    int i = 1;
                    stmt.setString(i++, newUserName);
                    stmt.setString(i++, newRole);
                    stmt.setString(i++, newFaculty);

                    if (newPassword != null && !newPassword.isEmpty()) {
                        stmt.setString(i++, newPassword);
                    }

                    stmt.setInt(i, userId);
                    stmt.executeUpdate();

                    // Update session attributes
                    session.setAttribute("user_name", newUserName);
                    session.setAttribute("role", newRole);
                    session.setAttribute("faculty", newFaculty);
                    
                    response.sendRedirect("homepage.jsp?message=Profile updated successfully!");
                    return;

                } catch (Exception e) {
                    message = "Update failed: " + e.getMessage();
                } finally {
                    if (stmt != null) {
                        stmt.close();
                    }
                    if (conn != null) {
                        conn.close();
                    }
                }
            }
        %>

        <div class="login-page"> <!-- Changed from "page" to "login-page" -->
            <div class="login-container"> <!-- Changed from "container" to "login-container" -->

                <div class="login-header">
                    <div class="logo-circle">👤</div> <!-- Changed from "header" to "login-header" -->
                    <h1>Edit Profile</h1>
                    <p>Update your iVote account information</p>
                </div>

                <% if (!message.isEmpty()) {%>
                <div class="login-error"><%= message%></div> <!-- Added error class -->
                <% }%>

                <form method="post">
                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="userName" value="<%= userName%>" required>
                    </div>

                    <div class="form-group">
                        <label>Email (cannot change)</label>
                        <input type="email" value="<%= email%>" disabled>
                    </div>

                    <div class="form-group">
                        <label>Role</label>
                        <select name="role" required>
                            <option value="student" <%= role.equals("student") ? "selected" : ""%>>Student</option>
                            <option value="lecturer" <%= role.equals("lecturer") ? "selected" : ""%>>Lecturer</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Faculty</label>
                        <select name="faculty" required>
                            <option value="<%= faculty%>"><%= faculty%></option>
                            <option value="CDCS230">CDCS230</option>
                            <option value="CDCS240">CDCS240</option>
                            <option value="CDCS241">CDCS241</option>
                            <option value="CDCS246">CDCS246</option>
                            <option value="CDCS247">CDCS247</option>
                            <option value="CDCS248">CDCS248</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>New Password</label>
                        <input type="password" name="password" placeholder="Leave blank to keep current">
                        <small style="display: block; margin-top: 0.4rem; font-size: 0.8rem; color: #888; font-style: italic;">
                            Enter a new password only if you want to change it
                        </small>
                    </div>

                    <button type="submit" class="login-btn">Update Profile</button> <!-- Changed from "btn" to "login-btn" -->
                </form>

                <div class="login-footer"> <!-- Changed from "footer" to "login-footer" -->
                    <a href="homepage.jsp">← Back to Homepage</a>
                </div>

            </div>
        </div>

    </body>
</html>