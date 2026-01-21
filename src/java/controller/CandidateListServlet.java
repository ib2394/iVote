package controller;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class CandidateListServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Map<String, Object>> candidates = new ArrayList<>();
        
        try {
            // 1. Connect to database
            Connection conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            
            // 2. Query database
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(
                "SELECT * FROM CANDIDATE ORDER BY candidateName");
            
            // 3. Process results
            while (rs.next()) {
                Map<String, Object> candidate = new HashMap<>();
                candidate.put("id", rs.getInt("candidateID"));
                candidate.put("name", rs.getString("candidateName"));
                candidate.put("email", rs.getString("candidateEmail"));
                candidate.put("program", rs.getString("program"));
                candidate.put("faculty", rs.getString("faculty"));
                candidate.put("desc", rs.getString("description"));
                candidates.add(candidate);
            }
            
            // 4. Close resources
            rs.close();
            stmt.close();
            conn.close();
            
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        // 5. Forward to JSP
        request.setAttribute("candidates", candidates);
        RequestDispatcher rd = request.getRequestDispatcher("viewCandidates.jsp");
        rd.forward(request, response);
    }
}