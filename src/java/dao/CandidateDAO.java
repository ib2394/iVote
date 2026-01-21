package dao;

import bean.Candidates;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CandidateDAO {

    public List<Candidates> getAllCandidates() {
        List<Candidates> candidates = new ArrayList<>();
        String query = "SELECT candidate_id, user_id, position_id, manifesto " +
                       "FROM Candidates ORDER BY candidate_id";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Candidates candidate = new Candidates();
                candidate.setCandidate_id(rs.getInt("candidate_id"));
                candidate.setUser_id(rs.getInt("user_id"));
                candidate.setPosition_id(rs.getInt("position_id"));
                candidate.setManifesto(rs.getString("manifesto"));
                candidates.add(candidate);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return candidates;
    }

    public boolean addCandidate(Candidates candidate) {
        String query = "INSERT INTO Candidates (user_id, position_id, manifesto) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, candidate.getUser_id());
            pstmt.setInt(2, candidate.getPosition_id());
            pstmt.setString(3, candidate.getManifesto());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateCandidate(Candidates candidate) {
        String query = "UPDATE Candidates SET user_id = ?, position_id = ?, manifesto = ? " +
                       "WHERE candidate_id = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, candidate.getUser_id());
            pstmt.setInt(2, candidate.getPosition_id());
            pstmt.setString(3, candidate.getManifesto());
            pstmt.setInt(4, candidate.getCandidate_id());

            return pstmt.executeUpdate() > 0;
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
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Candidates getCandidateById(int candidateId) {
        String query = "SELECT candidate_id, user_id, position_id, manifesto " +
                       "FROM Candidates WHERE candidate_id = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, candidateId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Candidates candidate = new Candidates();
                    candidate.setCandidate_id(rs.getInt("candidate_id"));
                    candidate.setUser_id(rs.getInt("user_id"));
                    candidate.setPosition_id(rs.getInt("position_id"));
                    candidate.setManifesto(rs.getString("manifesto"));
                    return candidate;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Candidates> getCandidatesByPosition(int positionId) {
        List<Candidates> candidates = new ArrayList<>();
        String query = "SELECT candidate_id, user_id, position_id, manifesto " +
                       "FROM Candidates WHERE position_id = ? ORDER BY candidate_id";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, positionId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Candidates candidate = new Candidates();
                    candidate.setCandidate_id(rs.getInt("candidate_id"));
                    candidate.setUser_id(rs.getInt("user_id"));
                    candidate.setPosition_id(rs.getInt("position_id"));
                    candidate.setManifesto(rs.getString("manifesto"));
                    candidates.add(candidate);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return candidates;
    }

    public List<Candidates> getCandidatesByUser(int userId) {
        List<Candidates> candidates = new ArrayList<>();
        String query = "SELECT candidate_id, user_id, position_id, manifesto " +
                       "FROM Candidates WHERE user_id = ? ORDER BY candidate_id";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Candidates candidate = new Candidates();
                    candidate.setCandidate_id(rs.getInt("candidate_id"));
                    candidate.setUser_id(rs.getInt("user_id"));
                    candidate.setPosition_id(rs.getInt("position_id"));
                    candidate.setManifesto(rs.getString("manifesto"));
                    candidates.add(candidate);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return candidates;
    }
}
