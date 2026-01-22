<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ page import="javax.servlet.http.*, java.io.*" %>
<%@ page import="java.sql.Connection, java.sql.DriverManager, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Login | iVote</title>
        <link rel="stylesheet" href="style.css">
    </head>

    <body class="login-body">       
        <div class="login-page">
            <div class="login-container">
                <div class="login-header">
                    <div class="logo-circle">🗳</div>
                    <h1>iVote Login</h1>
                    <p>Interactive Student Election System</p>
                </div>

                <form action="login.jsp" method="post">
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="user_name" required>
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
                        String user_name = request.getParameter("user_name");
                        String password = request.getParameter("password");

                        if (user_name != null && password != null) {
                            Connection conn = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;

                            try {
                                Class.forName("org.apache.derby.jdbc.ClientDriver");
                                conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");

                                String sql = "SELECT * FROM Users WHERE user_name=? AND password=?";
                                ps = conn.prepareStatement(sql);
                                ps.setString(1, user_name);
                                ps.setString(2, password);

                                rs = ps.executeQuery();

                                if (rs.next()) {
                                    // DEBUG: Print to server console
                                    System.out.println("LOGIN SUCCESS:");
                                    System.out.println("Username: " + user_name);
                                    System.out.println("User ID: " + rs.getInt("user_id"));
                                    System.out.println("Role from DB: " + rs.getString("role"));

                                    // Set session attributes
                                    session.setAttribute("user_id", rs.getInt("user_id"));
                                    session.setAttribute("user_name", rs.getString("user_name"));
                                    session.setAttribute("role", rs.getString("role"));

                                    String role = rs.getString("role");

                                    // DEBUG: Check role matching
                                    System.out.println("Role comparison:");
                                    System.out.println("Is admin? " + "admin".equalsIgnoreCase(role));
                                    System.out.println("Is student? " + "student".equalsIgnoreCase(role));
                                    System.out.println("Is lecturer? " + "lecturer".equalsIgnoreCase(role));

                                    if ("admin".equalsIgnoreCase(role)) {
                                        System.out.println("Redirecting to adminDashboard.jsp");
                                        response.sendRedirect("adminDashboard.jsp");
                                    } else if ("student".equalsIgnoreCase(role) || "lecturer".equalsIgnoreCase(role)) {
                                        System.out.println("Redirecting to homepage.jsp");
                                        response.sendRedirect("homepage.jsp");
                                    } else {
                                        System.out.println("Unknown role: " + role);
                                        out.println("<p style='color:red; text-align:center;'>Access denied. Unknown user role.</p>");
                                    }
                                    return;

                                } else {
                                    // Check if username exists
                                    String checkSql = "SELECT * FROM Users WHERE user_name=?";
                                    PreparedStatement checkPs = conn.prepareStatement(checkSql);
                                    checkPs.setString(1, user_name);
                                    ResultSet checkRs = checkPs.executeQuery();

                                    if (checkRs.next()) {
                                        System.out.println("LOGIN FAILED: Wrong password for user: " + user_name);
                                        out.println("<p style='color:red; text-align:center;'>Invalid password.</p>");
                                    } else {
                                        System.out.println("LOGIN FAILED: User not found: " + user_name);
                                        out.println("<p style='color:red; text-align:center;'>User not found.</p>");
                                    }

                                    checkRs.close();
                                    checkPs.close();
                                }

                            } catch (Exception e) {
                                System.out.println("LOGIN ERROR: " + e.getMessage());
                                e.printStackTrace();
                                out.println("<p style='color:red; text-align:center;'>Database error: " + e.getMessage() + "</p>");
                            } finally {
                                // Close resources
                            }
                        }
                    }
                %>
            </div>
        </div>
    </body>
</html>