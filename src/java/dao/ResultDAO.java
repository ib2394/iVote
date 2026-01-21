package dao;

import bean.CandidateResult;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ResultDAO {

    // Get results by election_id
    public List<CandidateResult> getResultsByElectionId(int election_id) {
        List<CandidateResult> results = new ArrayList<>();

        String query =
            "SELECT c.candidate_id, c.user_id, u.user_name, u.email, " +
            "       c.manifesto, " +
            "       COUNT(v.vote_id) AS vote_count, " +
            "       CASE WHEN tv.total_votes = 0 THEN 0 " +
            "            ELSE (COUNT(v.vote_id) * 100.0 / tv.total_votes) " +
            "       END AS percentage " +
            "FROM Candidates c " +
            "JOIN Users u ON c.user_id = u.user_id " +
            "LEFT JOIN Votes v ON v.candidate_id = c.candidate_id " +
            "LEFT JOIN ( " +
            "    SELECT candidate_id, COUNT(*) AS total_votes " +
            "    FROM Votes WHERE election_id = ? GROUP BY candidate_id " +
            ") tv ON tv.candidate_id = c.candidate_id " +
            "WHERE v.election_id = ? " +
            "GROUP BY c.candidate_id, c.user_id, u.user_name, u.email, c.manifesto, tv.total_votes " +
            "ORDER BY vote_count DESC";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, election_id);  // Set the election_id in the query
            ps.setInt(2, election_id);  // Filter by election_id for candidates

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CandidateResult cr = new CandidateResult();
                    cr.setCandidate_id(rs.getInt("candidate_id"));
                    cr.setUser_id(rs.getInt("user_id"));
                    cr.setUser_name(rs.getString("user_name"));
                    cr.setEmail(rs.getString("email"));
                    cr.setManifesto(rs.getString("manifesto"));
                    cr.setVote_count(rs.getInt("vote_count"));
                    cr.setPercentage(rs.getDouble("percentage"));
                    results.add(cr);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }

    // Get total votes for a specific election (filtered by election_id)
    public int getTotalVotesByElectionId(int election_id) {
        String query = "SELECT COUNT(*) FROM VOTE WHERE election_id = ?";
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, election_id);  // Use election_id for filtering
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
