package dao;

import bean.Position;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PositionDAO {

    public List<Position> getPositionsByElection(int electionId) {
        List<Position> positions = new ArrayList<>();
        String sql = "SELECT position_id, position_name, election_id " +
                     "FROM Positions WHERE election_id = ? ORDER BY position_name";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    positions.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return positions;
    }

    public Position getPositionById(int positionId) {
        String sql = "SELECT position_id, position_name, election_id " +
                     "FROM Positions WHERE position_id = ?";

        try (Connection conn = DBConnection.createConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, positionId);
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

    public int countPositionsByElection(int electionId) {
        String sql = "SELECT COUNT(*) FROM Positions WHERE election_id = ?";
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

    private Position mapRow(ResultSet rs) throws SQLException {
        Position p = new Position();
        p.setPosition_id(rs.getInt("position_id"));
        p.setPosition_name(rs.getString("position_name"));
        p.setElection_id(rs.getInt("election_id"));
        return p;
    }
}
