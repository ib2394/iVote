/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

import bean.CandidateResult;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ResultDAO {

    public List<CandidateResult> getResultsByPosition(int positionId) {
        List<CandidateResult> results = new ArrayList<>();

        String sql =
            "SELECT c.candidate_id, c.user_id, c.position_id, c.manifesto, " +
            "       u.user_name, u.email, p.position_name, " +
            "       COUNT(v.vote_id) AS vote_count, " +
            "       CASE WHEN tv.total_votes = 0 THEN 0 " +
            "            ELSE (COUNT(v.vote_id) * 100.0 / tv.total_votes) " +
            "       END AS percentage " +
            "FROM Candidates c " +
            "JOIN Users u ON c.user_id = u.user_id " +
            "JOIN Position p ON c.position_id = p.position_id " +
            "LEFT JOIN Votes v ON v.candidate_id = c.candidate_id AND v.position_id = c.position_id " +
            "LEFT JOIN (SELECT position_id, COUNT(*) AS total_votes FROM Votes WHERE position_id = ? GROUP BY position_id) tv " +
            "       ON tv.position_id = c.position_id " +
            "WHERE c.position_id = ? " +
            "GROUP BY c.candidate_id, c.user_id, c.position_id, c.manifesto, u.user_name, u.email, p.position_name, tv.total_votes " +
            "ORDER BY vote_count DESC";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, positionId);
            ps.setInt(2, positionId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CandidateResult cr = new CandidateResult();
                    cr.setCandidate_id(rs.getInt("candidate_id"));
                    cr.setUser_id(rs.getInt("user_id"));
                    cr.setPosition_id(rs.getInt("position_id"));
                    cr.setManifesto(rs.getString("manifesto"));
                    cr.setUser_name(rs.getString("user_name"));
                    cr.setEmail(rs.getString("email"));
                    cr.setPosition_name(rs.getString("position_name"));
                    cr.setVoteCount(rs.getInt("vote_count"));
                    cr.setPercentage(rs.getDouble("percentage"));
                    results.add(cr);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }

    public int getTotalVotesByPosition(int positionId) {
        String sql = "SELECT COUNT(*) FROM Votes WHERE position_id = ?";
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
