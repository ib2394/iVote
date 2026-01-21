/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

import bean.Vote;
import util.DBConnection;

import java.sql.*;

public class VoteDAO {

    // Cast a vote (insert into Votes)
    public boolean castVote(int userId, int candidateId, int positionId) {

        // optional: block if user already voted for this position
        if (hasVotedForPosition(userId, positionId)) {
            return false;
        }

        String query = "INSERT INTO Votes (user_id, candidate_id, position_id, vote_time) " +
                       "VALUES (?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, userId);
            pstmt.setInt(2, candidateId);
            pstmt.setInt(3, positionId);

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Check if a user already voted for a specific position
    public boolean hasVotedForPosition(int userId, int positionId) {
        String query = "SELECT COUNT(*) FROM Votes WHERE user_id = ? AND position_id = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, userId);
            pstmt.setInt(2, positionId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // If you want: check if user has voted at all (any position)
    public boolean hasVoted(int userId) {
        String query = "SELECT COUNT(*) FROM Votes WHERE user_id = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getTotalVotes() {
        String query = "SELECT COUNT(*) FROM Votes";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) return rs.getInt(1);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getVoterTurnout(int totalEligibleVoters) {
        int totalVotes = getTotalVotes();
        if (totalEligibleVoters > 0) {
            return (totalVotes * 100) / totalEligibleVoters;
        }
        return 0;
    }

    public int getTotalVotesByElection(int electionId) {
        String sql = "SELECT COUNT(*) FROM Votes v " +
                     "JOIN Positions p ON v.position_id = p.position_id " +
                     "WHERE p.election_id = ?";
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
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

    // OPTIONAL: get a Vote record by id
    public Vote getVoteById(int voteId) {
        String query = "SELECT vote_id, user_id, candidate_id, position_id, vote_time " +
                       "FROM Votes WHERE vote_id = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, voteId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Vote v = new Vote();
                    v.setVote_id(rs.getInt("vote_id"));
                    v.setUser_id(rs.getInt("user_id"));
                    v.setCandidate_id(rs.getInt("candidate_id"));
                    v.setPosition_id(rs.getInt("position_id"));
                    v.setVote_time(rs.getDate("vote_time")); // if your DB uses DATETIME/TIMESTAMP, you may prefer getTimestamp()
                    return v;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}

