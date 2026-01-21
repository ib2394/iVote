package dao;

import bean.Election;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ElectionDAO {

    public Election getActiveElection() {
        String sql = "SELECT election_id, election_name, start_date, end_date, status " +
                     "FROM Elections WHERE status = 'ACTIVE' " +
                     "ORDER BY start_date FETCH FIRST ROW ONLY";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Election getElectionById(int electionId) {
        String sql = "SELECT election_id, election_name, start_date, end_date, status " +
                     "FROM Elections WHERE election_id = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Election> getAll() {
        List<Election> elections = new ArrayList<>();
        String sql = "SELECT election_id, election_name, start_date, end_date, status " +
                     "FROM Elections ORDER BY start_date DESC";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                elections.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return elections;
    }

    public int countElections() {
        String sql = "SELECT COUNT(*) FROM Elections";
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean isActive(int electionId) {
        String sql = "SELECT status FROM Elections WHERE election_id = ?";
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "ACTIVE".equalsIgnoreCase(rs.getString("status"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Election mapRow(ResultSet rs) throws SQLException {
        Election election = new Election();
        election.setElection_id(rs.getInt("election_id"));
        election.setElection_name(rs.getString("election_name"));
        election.setStart_date(rs.getDate("start_date"));
        election.setEnd_date(rs.getDate("end_date"));
        election.setStatus(rs.getString("status"));
        return election;
    }
}
