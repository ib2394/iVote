package dao;

import bean.Candidates;
import util.DBConnection;
import bean.CandidateView;
import java.sql.*;
import java.util.ArrayList;
import java.util.*;

public class CandidateDAO {

    // In CandidateDAO.java
    public List<Map<String, String>> getCandidatesSimple(int electionId) {
        List<Map<String, String>> candidates = new ArrayList<>();
        String sql = "SELECT candidate_id, candidate_name, faculty, email, manifesto "
                + "FROM CANDIDATES WHERE election_id = ?";

        try (Connection conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, electionId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, String> candidate = new HashMap<>();
                candidate.put("candidate_id", String.valueOf(rs.getInt("candidate_id")));
                candidate.put("candidate_name", rs.getString("candidate_name"));
                candidate.put("faculty", rs.getString("faculty"));
                candidate.put("email", rs.getString("email"));
                candidate.put("manifesto", rs.getString("manifesto"));
                candidates.add(candidate);
            }

            System.out.println("CandidateDAO: Found " + candidates.size() + " candidates for election " + electionId);

        } catch (SQLException e) {
            System.out.println("CandidateDAO Error: " + e.getMessage());
            e.printStackTrace();
        }

        return candidates;
    }

    // Method untuk delete candidate
    public boolean deleteCandidate(int candidateId) {
        String query = "DELETE FROM CANDIDATES WHERE candidate_id = ?";

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, candidateId);

            // Execute delete
            int rowsAffected = pstmt.executeUpdate();
            boolean result = rowsAffected > 0;

            System.out.println("DEBUG: Delete candidate ID " + candidateId
                    + " - Rows affected: " + rowsAffected
                    + ", Success: " + result);

            return result;

        } catch (SQLException e) {
            System.err.println("Error deleting candidate ID " + candidateId + ": " + e.getMessage());

            // Check if error is due to foreign key constraint
            if (e.getSQLState().equals("23503")) { // Foreign key violation
                System.err.println("Cannot delete candidate. Candidate has related votes in the system.");
            }
            e.printStackTrace();
            return false;
        }
    }

    // Alternative: Delete with transaction and check for foreign key constraints
    public boolean deleteCandidateWithCheck(int candidateId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.createConnection();
            conn.setAutoCommit(false);

            String checkQuery = "SELECT COUNT(*) FROM CANDIDATES WHERE candidate_id = ?";
            pstmt = conn.prepareStatement(checkQuery);
            pstmt.setInt(1, candidateId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next() && rs.getInt(1) == 0) {
                System.out.println("DEBUG: Candidate ID " + candidateId + " does not exist.");
                return false;
            }
            String checkVotesQuery = "SELECT COUNT(*) FROM VOTE WHERE candidate_id = ?";
            pstmt = conn.prepareStatement(checkVotesQuery);
            pstmt.setInt(1, candidateId);
            rs = pstmt.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                System.out.println("WARNING: Candidate ID " + candidateId + " has "
                        + rs.getInt(1) + " votes. Proceeding with delete...");
            }

            String deleteQuery = "DELETE FROM CANDIDATES WHERE candidate_id = ?";
            pstmt = conn.prepareStatement(deleteQuery);
            pstmt.setInt(1, candidateId);

            int rowsAffected = pstmt.executeUpdate();

            conn.commit();

            boolean result = rowsAffected > 0;
            System.out.println("DEBUG: Delete candidate ID " + candidateId
                    + " - Success: " + result);

            return result;

        } catch (SQLException e) {
            // Rollback transaction if error
            if (conn != null) {
                try {
                    conn.rollback();
                    System.err.println("Transaction rolled back due to error.");
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }

            System.err.println("Error deleting candidate ID " + candidateId + ": " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            return false;

        } finally {
            // Close resources
            try {
                if (pstmt != null) {
                    pstmt.close();
                }
                if (conn != null) {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public List<CandidateView> getCandidateViewsByElection(int election_id) {
        List<CandidateView> candidates = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app")) {
            String sql = "SELECT * FROM CANDIDATES WHERE ELECTION_ID = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, election_id);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                CandidateView candidate = new CandidateView();
                candidate.setCandidate_id(rs.getInt("CANDIDATE_ID"));
                candidate.setUser_name(rs.getString("USER_NAME"));
                candidate.setEmail(rs.getString("EMAIL"));
                candidate.setFaculty(rs.getString("FACULTY"));
                candidate.setManifesto(rs.getString("MANIFESTO"));
                candidate.setElection_id(rs.getInt("ELECTION_ID"));
                candidates.add(candidate);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return candidates;
    }

    public List<CandidateView> getAllCandidateViews() {
        return getCandidateViewsByElection(0); //0 meaning is all elections
    }

    public List<Candidates> getAllCandidates() {
        List<Candidates> candidates = new ArrayList<>();

        String query = "SELECT "
                + "c.CANDIDATE_ID, "
                + "c.CANDIDATE_NAME, "
                + "c.FACULTY, "
                + "c.EMAIL, "
                + "c.MANIFESTO, "
                + "c.ELECTION_ID "
                + "FROM CANDIDATES c "
                + "ORDER BY c.CANDIDATE_ID";

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement stmt = conn.prepareStatement(query);
                ResultSet rs = stmt.executeQuery()) {

            System.out.println("DEBUG: Executing getAllCandidates query");

            int count = 0;
            while (rs.next()) {
                count++;
                Candidates candidate = new Candidates();
                candidate.setCandidate_id(rs.getInt("CANDIDATE_ID"));
                candidate.setCandidate_name(rs.getString("CANDIDATE_NAME"));
                candidate.setFaculty(rs.getString("FACULTY"));
                candidate.setEmail(rs.getString("EMAIL"));
                candidate.setManifesto(rs.getString("MANIFESTO"));
                candidate.setElection_id(rs.getInt("ELECTION_ID"));

                candidates.add(candidate);
                System.out.println("DEBUG: Loaded candidate #" + count + ": " + candidate.getCandidate_name());
            }

            System.out.println("DEBUG: Total candidates loaded: " + count);

        } catch (SQLException e) {
            System.err.println("Error in getAllCandidates: " + e.getMessage());
            e.printStackTrace();
        }
        return candidates;
    }

    // Method 3: Get total candidates count
    public int getTotalCandidates() {
        String sql = "SELECT COUNT(*) FROM CANDIDATES";
        try (Connection conn = DBConnection.createConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("DEBUG: Total candidates in DB: " + count);
                return count;
            }
        } catch (SQLException e) {
            System.err.println("Error in getTotalCandidates: " + e.getMessage());
        }
        return 0;
    }

    // Method 4: Add candidate (UPDATED - removed user_id)
    public boolean addCandidate(Candidates candidate) {
        String query = "INSERT INTO CANDIDATES (candidate_name, faculty, email, manifesto, election_id) "
                + "VALUES (?, ?, ?, ?, ?)";  // Only 5 values now

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, candidate.getCandidate_name());
            pstmt.setString(2, candidate.getFaculty());
            pstmt.setString(3, candidate.getEmail());
            pstmt.setString(4, candidate.getManifesto());
            pstmt.setInt(5, candidate.getElection_id());

            boolean result = pstmt.executeUpdate() > 0;
            System.out.println("DEBUG: Add candidate successful: " + result);
            return result;
        } catch (SQLException e) {
            System.err.println("Error in addCandidate: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Method 5: Update candidate (UPDATED - removed user_id)
    public boolean updateCandidate(Candidates candidate) {
        String query = "UPDATE CANDIDATES SET candidate_name = ?, faculty = ?, "
                + "email = ?, manifesto = ?, election_id = ? WHERE candidate_id = ?";

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, candidate.getCandidate_name());
            pstmt.setString(2, candidate.getFaculty());
            pstmt.setString(3, candidate.getEmail());
            pstmt.setString(4, candidate.getManifesto());
            pstmt.setInt(5, candidate.getElection_id());
            pstmt.setInt(6, candidate.getCandidate_id());

            boolean result = pstmt.executeUpdate() > 0;
            System.out.println("DEBUG: Update candidate successful: " + result);
            return result;
        } catch (SQLException e) {
            System.err.println("Error in updateCandidate: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Method 6: Get candidate by ID (UPDATED - removed user_id)
    public Candidates getCandidateById(int candidateId) {
        String query = "SELECT candidate_id, candidate_name, faculty, email, manifesto, election_id "
                + "FROM CANDIDATES WHERE candidate_id = ?";

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, candidateId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Candidates candidate = new Candidates();
                    candidate.setCandidate_id(rs.getInt("candidate_id"));
                    candidate.setCandidate_name(rs.getString("candidate_name"));
                    candidate.setFaculty(rs.getString("faculty"));
                    candidate.setEmail(rs.getString("email"));
                    candidate.setManifesto(rs.getString("manifesto"));
                    candidate.setElection_id(rs.getInt("election_id"));
                    return candidate;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getCandidateById: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // Method 7: Get candidates with vote counts (UPDATED - removed user_id)
    public List<CandidateView> getCandidatesWithVotes() {
        List<CandidateView> result = new ArrayList<>();
        String sql = "SELECT c.candidate_id, c.candidate_name, c.faculty, "
                + "c.email, c.manifesto, c.election_id, "
                + "e.election_name, " // Removed: u.user_name
                + "COALESCE(v.vote_count, 0) as vote_count "
                + "FROM CANDIDATES c "
                + "LEFT JOIN ELECTION e ON c.election_id = e.election_id "
                + "LEFT JOIN (SELECT candidate_id, COUNT(*) as vote_count "
                + "           FROM VOTE GROUP BY candidate_id) v "
                + "       ON c.candidate_id = v.candidate_id "
                + "ORDER BY vote_count DESC, c.candidate_name";

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                CandidateView view = new CandidateView();
                view.setCandidate_id(rs.getInt("candidate_id"));
                view.setCandidate_name(rs.getString("candidate_name"));
                view.setFaculty(rs.getString("faculty"));
                view.setEmail(rs.getString("email"));
                view.setManifesto(rs.getString("manifesto"));
                view.setElection_id(rs.getInt("election_id"));
                view.setElection_name(rs.getString("election_name"));
                view.setVote_count(rs.getInt("vote_count"));
                result.add(view);
            }
        } catch (SQLException e) {
            System.err.println("Error in getCandidatesWithVotes: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    // Method 8: Test database connection
    public boolean testConnection() {
        try (Connection conn = DBConnection.createConnection()) {
            System.out.println("=== Database Connection Test ===");
            System.out.println("Connected to: " + conn.getMetaData().getURL());
            System.out.println("Database: " + conn.getMetaData().getDatabaseProductName());
            return true;
        } catch (SQLException e) {
            System.err.println("Connection failed: " + e.getMessage());
            return false;
        }
    }

    // NEW METHOD: Get candidates by election ID (simplified)
    public List<Candidates> getCandidatesByElectionId(int electionId) {
        List<Candidates> candidates = new ArrayList<>();
        String query = "SELECT candidate_id, candidate_name, faculty, email, manifesto, election_id "
                + "FROM CANDIDATES WHERE election_id = ? ORDER BY candidate_name";

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, electionId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Candidates candidate = new Candidates();
                candidate.setCandidate_id(rs.getInt("candidate_id"));
                candidate.setCandidate_name(rs.getString("candidate_name"));
                candidate.setFaculty(rs.getString("faculty"));
                candidate.setEmail(rs.getString("email"));
                candidate.setManifesto(rs.getString("manifesto"));
                candidate.setElection_id(rs.getInt("election_id"));
                candidates.add(candidate);
            }
        } catch (SQLException e) {
            System.err.println("Error in getCandidatesByElectionId: " + e.getMessage());
            e.printStackTrace();
        }
        return candidates;
    }
}
