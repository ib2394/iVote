<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Edit Profile | iVote</title>

        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                margin: 0;
                min-height: 100vh;
            }

            .page {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .container {
                background: white;
                border-radius: 20px;
                padding: 3rem;
                width: 100%;
                max-width: 420px;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            }

            .header {
                text-align: center;
                margin-bottom: 2rem;
            }

            .header h1 {
                color: #667eea;
                margin-bottom: 0.5rem;
            }

            .header p {
                color: #666;
                font-size: 0.95rem;
            }

            .form-group {
                margin-bottom: 1.5rem;
            }

            .form-group label {
                display: block;
                margin-bottom: 0.4rem;
                font-weight: 500;
                color: #555;
            }

            .form-group input,
            .form-group select {
                width: 100%;
                padding: 0.8rem;
                border-radius: 10px;
                border: 2px solid #e0e0e0;
                font-size: 0.95rem;
            }

            .form-group input:focus,
            .form-group select:focus {
                outline: none;
                border-color: #667eea;
            }

            .btn {
                width: 100%;
                padding: 0.9rem;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 10px;
                font-size: 1rem;
                font-weight: 600;
                cursor: pointer;
            }

            .btn:hover {
                opacity: 0.9;
            }

            .footer {
                margin-top: 1.5rem;
                text-align: center;
                font-size: 0.9rem;
            }

            .footer a {
                color: #667eea;
                text-decoration: none;
                font-weight: 500;
            }

            .footer a:hover {
                text-decoration: underline;
            }

            .error {
                color: red;
                text-align: center;
                margin-bottom: 1rem;
            }
        </style>
    </head>

    <body>

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

                    response.sendRedirect("homepage.jsp?message=Profile updated");
                    return;

                } catch (Exception e) {
                    message = "Update failed.";
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

        <div class="page">
            <div class="container">

                <div class="header">
                    <h1>Edit Profile</h1>
                    <p>Update your iVote account</p>
                </div>

                <% if (!message.isEmpty()) {%>
                <div class="error"><%= message%></div>
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
                    </div>

                    <button type="submit" class="btn">Update Profile</button>
                </form>

                <div class="footer">
                    <a href="homepage.jsp">Cancel</a>
                </div>

            </div>
        </div>

    </body>
</html>
