package dao;

import bean.Candidates;
import util.DBConnection;
import bean.CandidateView;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CandidateDAO {

    // Method 1: Get candidate views by election (UPDATED - removed user_id)
    public List<CandidateView> getCandidateViewsByElection(int electionId) {
        List<CandidateView> views = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.createConnection();

            String query;
            if (electionId == 0) {
                query = "SELECT c.CANDIDATE_ID, c.CANDIDATE_NAME, c.FACULTY, "
                        + "c.EMAIL, c.MANIFESTO, c.ELECTION_ID, "
                        + "e.ELECTION_NAME "  // Removed: u.USER_NAME
                        + "FROM CANDIDATES c "
                        + "LEFT JOIN ELECTION e ON c.ELECTION_ID = e.ELECTION_ID "
                        + "ORDER BY c.CANDIDATE_ID";
            } else {
                query = "SELECT c.CANDIDATE_ID, c.CANDIDATE_NAME, c.FACULTY, "
                        + "c.EMAIL, c.MANIFESTO, c.ELECTION_ID, "
                        + "e.ELECTION_NAME "  // Removed: u.USER_NAME
                        + "FROM CANDIDATES c "
                        + "LEFT JOIN ELECTION e ON c.ELECTION_ID = e.ELECTION_ID "
                        + "WHERE c.ELECTION_ID = ? "
                        + "ORDER BY c.CANDIDATE_ID";
            }

            stmt = conn.prepareStatement(query);

            if (electionId != 0) {
                stmt.setInt(1, electionId);
            }

            rs = stmt.executeQuery();

            while (rs.next()) {
                CandidateView view = new CandidateView();
                view.setCandidate_id(rs.getInt("CANDIDATE_ID"));
                view.setCandidate_name(rs.getString("CANDIDATE_NAME"));
                view.setFaculty(rs.getString("FACULTY"));
                view.setEmail(rs.getString("EMAIL"));
                view.setManifesto(rs.getString("MANIFESTO"));
                view.setElection_name(rs.getString("ELECTION_NAME"));
                view.setElection_id(rs.getInt("ELECTION_ID"));

                views.add(view);
                System.out.println("DEBUG: Added candidate view - " + view.getCandidate_name());
            }

        } catch (SQLException e) {
            System.err.println("Error in getCandidateViewsByElection: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return views;
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
            conn.setAutoCommit(false); // Start transaction

            // 1. First check if candidate exists
            String checkQuery = "SELECT COUNT(*) FROM CANDIDATES WHERE candidate_id = ?";
            pstmt = conn.prepareStatement(checkQuery);
            pstmt.setInt(1, candidateId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next() && rs.getInt(1) == 0) {
                System.out.println("DEBUG: Candidate ID " + candidateId + " does not exist.");
                return false;
            }

            // 2. Check if candidate has votes (optional, untuk informative message)
            String checkVotesQuery = "SELECT COUNT(*) FROM VOTE WHERE candidate_id = ?";
            pstmt = conn.prepareStatement(checkVotesQuery);
            pstmt.setInt(1, candidateId);
            rs = pstmt.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                System.out.println("WARNING: Candidate ID " + candidateId + " has "
                        + rs.getInt(1) + " votes. Proceeding with delete...");
            }

            // 3. Delete the candidate
            String deleteQuery = "DELETE FROM CANDIDATES WHERE candidate_id = ?";
            pstmt = conn.prepareStatement(deleteQuery);
            pstmt.setInt(1, candidateId);

            int rowsAffected = pstmt.executeUpdate();

            // Commit transaction
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

    // REMOVED: deleteCandidateByUserId method (no longer needed since we removed user_id)

    // Method alternatif untuk semua candidate views
    public List<CandidateView> getAllCandidateViews() {
        return getCandidateViewsByElection(0); // 0 untuk semua election
    }

    // Method 2: Get all candidates (UPDATED - removed user_id)
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
                + "e.election_name, "  // Removed: u.user_name
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