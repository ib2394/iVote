<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ page import="javax.servlet.http.*, java.io.*" %>
<%@ page import="java.sql.*" %>
<%@page import="java.nio.file.*"%>
<%@page import="javax.servlet.http.Part"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Register | iVote</title>

        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                margin: 0;
                min-height: 100vh;
            }

            .register-page {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .register-container {
                background: white;
                border-radius: 20px;
                padding: 3rem;
                width: 100%;
                max-width: 420px;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            }

            .register-header {
                text-align: center;
                margin-bottom: 2rem;
            }

            .logo-circle {
                font-size: 3rem;
                margin-bottom: 1rem;
            }

            .register-header h1 {
                color: #667eea;
                margin-bottom: 0.5rem;
            }

            .register-header p {
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

            .register-btn {
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

            .register-btn:hover {
                opacity: 0.9;
            }

            .register-footer {
                margin-top: 1.5rem;
                text-align: center;
                font-size: 0.9rem;
                color: #666;
            }

            .register-footer a {
                color: #667eea;
                text-decoration: none;
                font-weight: 500;
            }

            .register-footer a:hover {
                text-decoration: underline;
            }
        </style>
    </head>

    <body>

        <div class="register-page">
            <div class="register-container">

                <div class="register-header">
                    <div class="logo-circle">🗳️</div>
                    <h1>iVote Registration</h1>
                    <p>Create your iVote account</p>
                </div>

                <form action="register.jsp" method="post" enctype="multipart/form-data">

                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="userName" required>
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" required>
                    </div>

                    <div class="form-group">
                        <label>Faculty</label>
                        <select name="program" required>
                            <option value="CDCS230">---Select Program---</option>
                            <option value="CDCS230">CDCS230</option>
                            <option value="CDCS240">CDCS240</option>
                            <option value="CDCS241">CDCS241</option>
                            <option value="CDCS246">CDCS246</option>
                            <option value="CDCS247">CDCS247</option>
                            <option value="CDCS248">CDCS248</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="userPass" required>
                    </div>

                    <div class="form-group">
                        <label>Role</label>
                        <select name="userCategory" required>
                            <option value="">Select Role</option>
                            <option value="student">Student</option>
                            <option value="lecturer">Lecturer</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Profile Picture</label>
                        <input type="file" name="profilePic" accept="image/*" required>
                    </div>

                    <button type="submit" class="register-btn">Register</button>
                </form>

                <div class="register-footer">
                    Already have an account?
                    <a href="login.jsp">Login here</a>
                </div>

                <%
                    if ("POST".equalsIgnoreCase(request.getMethod())) {

                        String fullName = request.getParameter("userName");
                        String email = request.getParameter("email");
                        String faculty = request.getParameter("faculty");
                        String password = request.getParameter("userPass");
                        String role = request.getParameter("userCategory");

                        // Handle profile picture upload
                        Part filePart = request.getPart("profilePic");
                        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

                        // Change this path if needed
                        String uploadPath = application.getRealPath("/") + "profile_pics";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdir();
                        }

                        String filePath = uploadPath + File.separator + fileName;
                        filePart.write(filePath);

                        Connection conn = null;
                        PreparedStatement stmt = null;

                        try {
                            conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");

                            String sql = "INSERT INTO Users " + "(full_name, email, faculty, password, role, profile_pic) "
                                    + "VALUES (?, ?, ?, ?, ?, ?)";

                            stmt = conn.prepareStatement(sql);
                            stmt.setString(1, fullName);
                            stmt.setString(2, email);
                            stmt.setString(3, faculty);
                            stmt.setString(4, password);
                            stmt.setString(5, role);
                            stmt.setString(6, fileName);

                            stmt.executeUpdate();

                            out.println("<p style='color:green; text-align:center;'>");
                            out.println("Registration successful!<br>");
                            out.println("<a href='login.jsp'>Proceed to Login</a>");
                            out.println("</p>");

                        } catch (SQLException e) {
                            out.println("<p style='color:red; text-align:center;'>");
                            out.println("Error: " + e.getMessage());
                            out.println("</p>");
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

            </div>
        </div>

    </body>
</html>
