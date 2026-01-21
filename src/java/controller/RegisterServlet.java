package controller;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // Retrieve form data
        String user_name = request.getParameter("user_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String faculty = request.getParameter("faculty");  
        
        // For new registration: 
        // If status means "voting status" - set to "not_voted"
        // If status means "account status" - set to "active"
        String status = "not_voted"; // or "active" depending on your system

        // Debugging statements
        System.out.println("=== Registration Debug ===");
        System.out.println("User Name: " + user_name);
        System.out.println("Email: " + email);
        System.out.println("Password: " + password);
        System.out.println("Role: " + role);
        System.out.println("Faculty: " + faculty);
        System.out.println("Status (default): " + status);
        
        // Print all parameters for debugging
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            System.out.println(paramName + ": " + request.getParameter(paramName));
        }

        // Check if any required parameter is missing or empty
        if (user_name == null || user_name.trim().isEmpty()) {
            response.getWriter().println("<p style='color:red;'>Username is required!</p>");
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            response.getWriter().println("<p style='color:red;'>Email is required!</p>");
            return;
        }
        if (password == null || password.trim().isEmpty()) {
            response.getWriter().println("<p style='color:red;'>Password is required!</p>");
            return;
        }
        if (faculty == null || faculty.trim().isEmpty()) {
            response.getWriter().println("<p style='color:red;'>Faculty is required!</p>");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DriverManager.getConnection(
                     "jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            
            // Check if username already exists
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT user_id FROM USERS WHERE user_name = ? OR email = ?");
            checkStmt.setString(1, user_name.trim());
            checkStmt.setString(2, email.trim());
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                response.getWriter().println("<p style='color:red;'>Username or email already exists!</p>");
                return;
            }
            
            // Default role to "user" if not specified
            if (role == null || role.trim().isEmpty()) {
                role = "user";
            }
            
            // Insert new user
            stmt = conn.prepareStatement(
                     "INSERT INTO USERS (user_name, password, email, role, status, faculty) VALUES (?, ?, ?, ?, ?, ?)");

            stmt.setString(1, user_name.trim());  // USER_NAME
            stmt.setString(2, password.trim());   // PASSWORD (in real app, hash this!)
            stmt.setString(3, email.trim());      // EMAIL
            stmt.setString(4, role.trim());       // ROLE
            stmt.setString(5, status);            // STATUS ("not_voted" for new users)
            stmt.setString(6, faculty.trim());    // FACULTY

            int rowsInserted = stmt.executeUpdate();
            
            if (rowsInserted > 0) {
                System.out.println("User registered successfully: " + user_name);
                // Redirect to login page with success message
                response.sendRedirect("login.jsp?message=Registration successful! Please login.");
            } else {
                response.getWriter().println("<p style='color:red;'>Registration failed. Please try again.</p>");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("<p style='color:red;'>Database Error: " + e.getMessage() + "</p>");
        } finally {
            // Close resources
            try { if (stmt != null) stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to the registration form
        response.sendRedirect("register.jsp");
    }
}