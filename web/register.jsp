<%@ page language="java" contentType="text/html;charset=UTF-8" %>

<%@ page import="java.io.File" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>

<%@ page import="javax.servlet.http.Part" %>
<%@ page import="java.nio.file.Paths" %>



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
                    <div class="logo-circle">🗳</div>
                    <h1>iVote Registration</h1>
                    <p>Create your iVote account</p>
                </div>

                <form action="RegisterServlet" method="post">

                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="user_name" required>
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" required>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="password" required>
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
                        <label>Faculty</label>
                        <select name="faculty" required>
                            <option value="">Select Faculty</option>
                            <option value="CDCS230">CDCS230</option>
                            <option value="CDCS240">CDCS240</option>
                            <option value="CDCS241">CDCS241</option>
                            <option value="CDCS246">CDCS246</option>
                            <option value="CDCS247">CDCS247</option>
                            <option value="CDCS248">CDCS248</option>
                        </select>
                    </div>

                    <button type="submit" class="register-btn">Register</button>
                </form>

                <div class="register-footer">
                    Already have an account?
                    <a href="login.jsp">Login here</a>
                </div>
            </div>
        </div>

    </body>
</html>