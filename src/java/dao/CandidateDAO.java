package dao;

import bean.Candidate;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CandidateDAO {
    
    public List<Candidate> getAllCandidates() {
        List<Candidate> candidates = new ArrayList<>();
        String query = "SELECT c.*, COUNT(v.vote_id) as vote_count " +
                      "FROM Candidates c " +
                      "LEFT JOIN Votes v ON c.candidate_id = v.candidate_id " +
                      "GROUP BY c.candidate_id " +
                      "ORDER BY vote_count DESC";
        
        try (Connection conn = DBConnection.createConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            while (rs.next()) {
                Candidate candidate = new Candidate();
                candidate.setCandidateId(rs.getInt("candidate_id"));
                candidate.setCandidateName(rs.getString("candidate_name"));
                candidate.setEmail(rs.getString("email"));
                candidate.setProgram(rs.getString("program"));
                candidate.setFaculty(rs.getString("faculty"));
                candidate.setDescription(rs.getString("description"));
                candidate.setPhotoUrl(rs.getString("photo_url"));
                candidate.setVoteCount(rs.getInt("vote_count"));
                
                candidates.add(candidate);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return candidates;
    }
    
    public boolean addCandidate(Candidate candidate) {
        String query = "INSERT INTO Candidates (candidate_name, email, program, faculty, description, photo_url) " +
                      "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, candidate.getCandidateName());
            pstmt.setString(2, candidate.getEmail());
            pstmt.setString(3, candidate.getProgram());
            pstmt.setString(4, candidate.getFaculty());
            pstmt.setString(5, candidate.getDescription());
            pstmt.setString(6, candidate.getPhotoUrl());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateCandidate(Candidate candidate) {
        String query = "UPDATE Candidates SET candidate_name = ?, email = ?, program = ?, " +
                      "faculty = ?, description = ?, photo_url = ? WHERE candidate_id = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, candidate.getCandidateName());
            pstmt.setString(2, candidate.getEmail());
            pstmt.setString(3, candidate.getProgram());
            pstmt.setString(4, candidate.getFaculty());
            pstmt.setString(5, candidate.getDescription());
            pstmt.setString(6, candidate.getPhotoUrl());
            pstmt.setInt(7, candidate.getCandidateId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteCandidate(int candidateId) {
        String query = "DELETE FROM Candidates WHERE candidate_id = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setInt(1, candidateId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public Candidate getCandidateById(int candidateId) {
        Candidate candidate = null;
        String query = "SELECT * FROM Candidates WHERE candidate_id = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setInt(1, candidateId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                candidate = new Candidate();
                candidate.setCandidateId(rs.getInt("candidate_id"));
                candidate.setCandidateName(rs.getString("candidate_name"));
                candidate.setEmail(rs.getString("email"));
                candidate.setProgram(rs.getString("program"));
                candidate.setFaculty(rs.getString("faculty"));
                candidate.setDescription(rs.getString("description"));
                candidate.setPhotoUrl(rs.getString("photo_url"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return candidate;
    }
}