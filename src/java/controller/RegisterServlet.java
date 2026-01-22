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
        String status = "active"; // Account status

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
            request.setAttribute("errorMessage", "Username is required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Email is required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Password is required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (faculty == null || faculty.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Faculty is required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        // Validate role - only allow admin, student, or lecturer
        if (role == null || role.trim().isEmpty()) {
            role = "student"; // Default to student
        } else if (!"admin".equalsIgnoreCase(role) && 
                   !"student".equalsIgnoreCase(role) && 
                   !"lecturer".equalsIgnoreCase(role)) {
            request.setAttribute("errorMessage", "Invalid role selected. Please choose student, lecturer, or admin.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DriverManager.getConnection(
                     "jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            
            // Check if username or email already exists
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT user_id FROM USERS WHERE LOWER(user_name) = LOWER(?) OR LOWER(email) = LOWER(?)");
            checkStmt.setString(1, user_name.trim());
            checkStmt.setString(2, email.trim());
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                request.setAttribute("errorMessage", "Username or email already exists!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Insert new user
            stmt = conn.prepareStatement(
                     "INSERT INTO USERS (user_name, password, email, role, status, faculty) VALUES (?, ?, ?, ?, ?, ?)");

            stmt.setString(1, user_name.trim());  // USER_NAME
            stmt.setString(2, password.trim());   // PASSWORD (in real app, hash this!)
            stmt.setString(3, email.trim());      // EMAIL
            stmt.setString(4, role.toLowerCase()); // ROLE (convert to lowercase for consistency)
            stmt.setString(5, status);            // STATUS ("active" for new users)
            stmt.setString(6, faculty.trim());    // FACULTY

            int rowsInserted = stmt.executeUpdate();
            
            if (rowsInserted > 0) {
                System.out.println("User registered successfully: " + user_name + " with role: " + role);
                
                // For admin registrations, you might want to redirect differently
                if ("admin".equalsIgnoreCase(role)) {
                    request.setAttribute("successMessage", "Admin account created successfully!");
                    request.getRequestDispatcher("register.jsp").forward(request, response);
                } else {
                    // For student/lecturer, redirect to login
                    response.sendRedirect("login.jsp?message=Registration successful! Please login.");
                }
            } else {
                request.setAttribute("errorMessage", "Registration failed. Please try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database Error: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
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