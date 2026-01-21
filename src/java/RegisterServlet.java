import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // Retrieve form data
        String fullName = request.getParameter("userName");
        String email = request.getParameter("email");
        String password = request.getParameter("userPass");
        String role = request.getParameter("userCategory");
        String faculty = request.getParameter("faculty");  

        // Debugging statements
        System.out.println("Full Name: " + fullName);
        System.out.println("Email: " + email);
        System.out.println("Password: " + password);
        System.out.println("Role: " + role);
        System.out.println("Faculty: " + faculty);  // Debugging faculty field

        // Check if any required parameter is missing
        if (fullName == null || email == null || password == null || role == null || faculty == null) {
            response.getWriter().println("<p style='color:red;'>Missing required fields!</p>");
            return;  // Stop execution if any required field is missing
        }

        try (Connection conn = DriverManager.getConnection(
                     "jdbc:derby://localhost:1527/iVoteDB", "app", "app");
             PreparedStatement stmt = conn.prepareStatement(
                     "INSERT INTO Users (user_name, password, email, role, faculty) VALUES (?, ?, ?, ?, ?)")) {

            stmt.setString(1, fullName);  // USER_NAME
            stmt.setString(2, password);  // PASSWORD (hashed)
            stmt.setString(3, email);  // EMAIL
            stmt.setString(4, role);  // ROLE
            stmt.setString(5, faculty);  // FACULTY

            stmt.executeUpdate();

            // Redirect to login page and pass a success message using request attribute
            response.sendRedirect("login.jsp?signup=success");

        } catch (Exception e) {
            response.getWriter().println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }
}

