<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ page import="javax.servlet.http.*, java.io.*" %>
<%@ page import="java.sql.Connection, java.sql.DriverManager, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Login | iVote</title>

        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                margin: 0;
                min-height: 100vh;
            }

            .login-page {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .login-container {
                background: white;
                border-radius: 20px;
                padding: 3rem;
                width: 100%;
                max-width: 420px;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            }

            .login-header {
                text-align: center;
                margin-bottom: 2rem;
            }

            .logo-circle {
                font-size: 3rem;
                margin-bottom: 1rem;
            }

            .login-header h1 {
                color: #667eea;
                margin-bottom: 0.5rem;
            }

            .login-header p {
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

            .login-btn {
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

            .login-btn:hover {
                opacity: 0.9;
            }

            .login-footer {
                margin-top: 1.5rem;
                text-align: center;
                font-size: 0.9rem;
                color: #666;
            }

            .login-footer a {
                color: #667eea;
                text-decoration: none;
                font-weight: 500;
            }

            .login-footer a:hover {
                text-decoration: underline;
            }
        </style>
    </head>

    <body>

        <div class="login-page">
            <div class="login-container">

                <div class="login-header">
                    <div class="logo-circle">🗳️</div>
                    <h1>iVote Login</h1>
                    <p>Interactive Student Election System</p>
                </div>

                <form action="login.jsp" method="post">

                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="userName" required>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="password" required>
                    </div>

                    <button type="submit" class="login-btn">Login</button>
                </form>

                <div class="login-footer">
                    Don’t have an account?
                    <a href="register.jsp">Create one now</a>
                </div>

                <%
                    if ("POST".equalsIgnoreCase(request.getMethod())) {
                        String userName = request.getParameter("userName");
                        String password = request.getParameter("password");

                        if (userName != null && password != null) {
                            Connection conn = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;

                            try {
                                Class.forName("org.apache.derby.jdbc.ClientDriver");
                                conn = DriverManager.getConnection(
                                        "jdbc:derby://localhost:1527/iVoteDB", "app", "app");

                                String sql = "SELECT * FROM Users WHERE user_name=? AND password=?";
                                ps = conn.prepareStatement(sql);
                                ps.setString(1, userName);
                                ps.setString(2, password);

                                rs = ps.executeQuery();

                                if (rs.next()) {
                                    session.setAttribute("user_id", rs.getInt("user_id"));   // 🔑 REQUIRED
                                    session.setAttribute("userName", rs.getString("user_name"));
                                    session.setAttribute("role", rs.getString("role"));      // optional

                                    response.sendRedirect("editProfile.jsp");
                                } else {
                %>
                <p style="color:red; text-align:center;">Invalid username or password.</p>
                <%
                                }

                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<p style='color:red; text-align:center;'>Error connecting to database.</p>");
                            } finally {
                                try {
                                    if (rs != null) {
                                        rs.close();
                                    }
                                } catch (SQLException e) {
                                }
                                try {
                                    if (ps != null) {
                                        ps.close();
                                    }
                                } catch (SQLException e) {
                                }
                                try {
                                    if (conn != null) {
                                        conn.close();
                                    }
                                } catch (SQLException e) {
                                }
                            }
                        } else {
                            out.println("<p style='color:red; text-align:center;'>Please fill in both fields.</p>");
                        }
                    }
                %>

            </div>
        </div>
    </body>
</html>