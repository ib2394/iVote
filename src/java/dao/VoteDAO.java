/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

import com.java.bean.Vote;
import util.DBConnection;
import java.sql.*;

public class VoteDAO {
    
    public boolean castVote(int voterId, int candidateId, String ipAddress) {
        // Check if user has already voted
        if (hasVoted(voterId)) {
            return false;
        }
        
        String query = "INSERT INTO Votes (voter_id, candidate_id, ip_address) VALUES (?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection()) {
            // Start transaction
            conn.setAutoCommit(false);
            
            try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                pstmt.setInt(1, voterId);
                pstmt.setInt(2, candidateId);
                pstmt.setString(3, ipAddress);
                
                int rowsAffected = pstmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    // Update user's vote status
                    UserDAO userDAO = new UserDAO();
                    if (userDAO.updateVoteStatus(voterId)) {
                        conn.commit();
                        return true;
                    }
                }
                conn.rollback();
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean hasVoted(int voterId) {
        String query = "SELECT COUNT(*) FROM Votes WHERE voter_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setInt(1, voterId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public int getTotalVotes() {
        String query = "SELECT COUNT(*) FROM Votes";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
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
}