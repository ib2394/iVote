// VoteServlet.java
import java.io.*;
import java.sql.*;
import java.time.LocalDateTime;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

public class VotingServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer user_id = (Integer) session.getAttribute("user_id");
        
        if (user_id == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get parameters
        String candidate_id_str = request.getParameter("candidate_id");
        String election_id_str = request.getParameter("election_id");
        
        if (candidate_id_str == null || election_id_str == null || 
            candidate_id_str.isEmpty() || election_id_str.isEmpty()) {
            response.sendRedirect("VotingPage.jsp?message=Missing parameters&status=error");
            return;
        }
        
        try {
            int candidate_id = Integer.parseInt(candidate_id_str);
            int election_id = Integer.parseInt(election_id_str);
            
            // Check if user already voted
            if (hasVoted(user_id, election_id)) {
                response.sendRedirect("VotingPage.jsp?election_id=" + election_id + 
                                     "&message=You have already voted in this election&status=error");
                return;
            }
            
            // Record the vote
            boolean success = recordVote(user_id, candidate_id, election_id);
            
            if (success) {
                // Update user status to 'voted'
                updateUserStatus(user_id);
                
                response.sendRedirect("VotingPage.jsp?election_id=" + election_id + 
                                     "&message=Vote recorded successfully&status=success");
            } else {
                response.sendRedirect("VotingPage.jsp?election_id=" + election_id + 
                                     "&message=Failed to record vote&status=error");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("VotingPage.jsp?message=Error: " + e.getMessage() + "&status=error");
        }
    }
    
    private boolean hasVoted(int user_id, int election_id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            
            String sql = "SELECT COUNT(*) as count FROM VOTE WHERE USER_ID = ? AND ELECTION_ID = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, user_id);
            ps.setInt(2, election_id);
            
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
        return false;
    }
    
    private boolean recordVote(int user_id, int candidate_id, int election_id) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            
            // Insert into VOTE table
            String sql = "INSERT INTO VOTE (USER_ID, CANDIDATE_ID, ELECTION_ID, VOTE_TIME) " +
                         "VALUES (?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, user_id);
            ps.setInt(2, candidate_id);
            ps.setInt(3, election_id);
            ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
            
            int rows = ps.executeUpdate();
            return rows > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    private void updateUserStatus(int user_id) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            
            String sql = "UPDATE USERS SET STATUS = 'voted' WHERE USER_ID = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, user_id);
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}