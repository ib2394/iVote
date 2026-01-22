package controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;

@WebServlet("/VotingServlet") // Add this annotation
public class VotingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String candidateIdParam = request.getParameter("candidate_id");
        String electionIdParam = request.getParameter("election_id");

        System.out.println("DEBUG VotingServlet: candidate_id=" + candidateIdParam + ", election_id=" + electionIdParam);

        if (candidateIdParam == null || electionIdParam == null) {
            System.out.println("DEBUG VotingServlet: Missing parameters");
            response.sendRedirect("VotingPage.jsp?error=Invalid vote parameters.");
            return;
        }

        int candidateId = 0;
        int electionId = 0;
        try {
            candidateId = Integer.parseInt(candidateIdParam);
            electionId = Integer.parseInt(electionIdParam);
            System.out.println("DEBUG VotingServlet: Parsed candidateId=" + candidateId + ", electionId=" + electionId);
        } catch (NumberFormatException e) {
            System.out.println("DEBUG VotingServlet: Number format exception");
            response.sendRedirect("VotingPage.jsp?error=Invalid number format.");
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("DEBUG VotingServlet: No session");
            response.sendRedirect("login.jsp");
            return;
        }

        Integer userId = (Integer) session.getAttribute("user_id");
        if (userId == null) {
            // Try to get from request parameter as fallback
            String userIdParam = request.getParameter("user_id");
            if (userIdParam != null) {
                try {
                    userId = Integer.parseInt(userIdParam);
                    session.setAttribute("user_id", userId);
                    System.out.println("DEBUG VotingServlet: Got user_id from parameter: " + userId);
                } catch (NumberFormatException e) {
                    System.out.println("DEBUG VotingServlet: Invalid user_id parameter");
                    response.sendRedirect("login.jsp");
                    return;
                }
            } else {
                System.out.println("DEBUG VotingServlet: No user_id in session or parameters");
                response.sendRedirect("login.jsp");
                return;
            }
        }

        System.out.println("DEBUG VotingServlet: User ID = " + userId);

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            conn = DriverManager.getConnection(
                "jdbc:derby://localhost:1527/iVoteDB", "app", "app");

            // Check if user already voted for this election (no position anymore)
            String checkSql = "SELECT 1 FROM APP.VOTE WHERE USER_ID = ? AND ELECTION_ID = ?";
            ps = conn.prepareStatement(checkSql);
            ps.setInt(1, userId);
            ps.setInt(2, electionId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                System.out.println("DEBUG VotingServlet: User already voted in this election");
                response.sendRedirect("VotingPage.jsp?election_id=" + electionId + "&error=You have already voted in this election.");
                return;
            }
            rs.close();
            ps.close();

            // Insert vote - NO POSITION_ID anymore
            String insertSql = "INSERT INTO APP.VOTE (USER_ID, CANDIDATE_ID, VOTE_TIME, ELECTION_ID) " +
                               "VALUES (?, ?, CURRENT_TIMESTAMP, ?)";
            ps = conn.prepareStatement(insertSql);
            ps.setInt(1, userId);
            ps.setInt(2, candidateId);
            ps.setInt(3, electionId);

            // Verify candidate exists in this election
            PreparedStatement ps2 = conn.prepareStatement(
                "SELECT 1 FROM APP.CANDIDATES WHERE CANDIDATE_ID = ? AND ELECTION_ID = ?");
            ps2.setInt(1, candidateId);
            ps2.setInt(2, electionId);
            ResultSet rs2 = ps2.executeQuery();
            if (!rs2.next()) {
                System.out.println("DEBUG VotingServlet: Candidate not found in this election");
                response.sendRedirect("VotingPage.jsp?election_id=" + electionId + "&error=Candidate not found in this election.");
                return;
            }
            rs2.close();
            ps2.close();

            // Execute the insert
            int rowsAffected = ps.executeUpdate();
            System.out.println("DEBUG VotingServlet: Rows affected = " + rowsAffected);

            if (rowsAffected > 0) {
                System.out.println("DEBUG VotingServlet: Vote recorded successfully");
                response.sendRedirect("VotingPage.jsp?election_id=" + electionId + "&vote=success");
            } else {
                System.out.println("DEBUG VotingServlet: No rows affected");
                response.sendRedirect("VotingPage.jsp?election_id=" + electionId + "&error=Failed to record vote.");
            }

        } catch (ClassNotFoundException e) {
            System.err.println("DEBUG VotingServlet: Driver not found");
            e.printStackTrace();
            response.sendRedirect("VotingPage.jsp?election_id=" + electionId + "&error=Database driver error.");
        } catch (SQLException e) {
            System.err.println("DEBUG VotingServlet: SQL Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("VotingPage.jsp?election_id=" + electionId + "&error=Database error: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("DEBUG VotingServlet: General error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("VotingPage.jsp?election_id=" + electionId + "&error=Failed to record vote.");
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}