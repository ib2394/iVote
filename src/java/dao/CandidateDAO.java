package dao;

import bean.CandidateView;
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

    public int getTotalCandidates() {
        String sql = "SELECT COUNT(*) FROM Candidates";
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
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

    public List<CandidateView> getCandidateViewsByElection(int electionId) {
        List<CandidateView> result = new ArrayList<>();
        String sql = "SELECT c.candidate_id, c.user_id, u.user_name, u.email, " +
                     "       c.position_id, p.position_name, p.election_id, e.election_name, " +
                     "       c.manifesto " +
                     "FROM Candidates c " +
                     "JOIN Users u ON c.user_id = u.user_id " +
                     "JOIN Positions p ON c.position_id = p.position_id " +
                     "JOIN Elections e ON p.election_id = e.election_id " +
                     "WHERE p.election_id = ? " +
                     "ORDER BY p.position_name, u.user_name";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CandidateView view = new CandidateView();
                    view.setCandidateId(rs.getInt("candidate_id"));
                    view.setUserId(rs.getInt("user_id"));
                    view.setUserName(rs.getString("user_name"));
                    view.setEmail(rs.getString("email"));
                    view.setPositionId(rs.getInt("position_id"));
                    view.setPositionName(rs.getString("position_name"));
                    view.setElectionId(rs.getInt("election_id"));
                    view.setElectionName(rs.getString("election_name"));
                    view.setManifesto(rs.getString("manifesto"));
                    result.add(view);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public List<CandidateView> getCandidateViewsByPosition(int positionId) {
        List<CandidateView> result = new ArrayList<>();
        String sql = "SELECT c.candidate_id, c.user_id, u.user_name, u.email, " +
                     "       c.position_id, p.position_name, p.election_id, e.election_name, " +
                     "       c.manifesto " +
                     "FROM Candidates c " +
                     "JOIN Users u ON c.user_id = u.user_id " +
                     "JOIN Positions p ON c.position_id = p.position_id " +
                     "JOIN Elections e ON p.election_id = e.election_id " +
                     "WHERE c.position_id = ? " +
                     "ORDER BY u.user_name";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CandidateView view = new CandidateView();
                    view.setCandidateId(rs.getInt("candidate_id"));
                    view.setUserId(rs.getInt("user_id"));
                    view.setUserName(rs.getString("user_name"));
                    view.setEmail(rs.getString("email"));
                    view.setPositionId(rs.getInt("position_id"));
                    view.setPositionName(rs.getString("position_name"));
                    view.setElectionId(rs.getInt("election_id"));
                    view.setElectionName(rs.getString("election_name"));
                    view.setManifesto(rs.getString("manifesto"));
                    result.add(view);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
}
