/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

import bean.Users;
import util.DBConnection;
import java.sql.*;
import java.util.*;

public class UserDAO {

    public Users authenticateUser(String email, String password) {
        Users user = null;
        String query = "SELECT user_id, user_name, password, email, role, status,faculty "
                + "FROM Users WHERE email = ? AND password = ?";

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, email);
            pstmt.setString(2, password);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = new Users();
                    user.setUser_id(rs.getInt("user_id"));
                    user.setUser_name(rs.getString("user_name"));
                    user.setPassword(rs.getString("password"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setStatus(rs.getString("faculty"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    public boolean registerUser(Users user) {
        String query = "INSERT INTO Users (user_name, password, email, role, status, faculty) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, user.getUser_name());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getRole());
            pstmt.setString(5, user.getStatus());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateUserStatus(int userId, String status) {
        String query = "UPDATE Users SET status = ? WHERE user_id = ?";

        try (Connection conn = DBConnection.createConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, status);
            pstmt.setInt(2, userId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int countByRole(String role) {
        String query = "SELECT COUNT(*) FROM Users WHERE role = ?";
        try (Connection conn = DBConnection.createConnection();
                PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Users getUserById(int userId) {
        String query = "SELECT user_id, user_name, password, email, role, status, faculty "
                + "FROM Users WHERE user_id = ?";
        try (Connection conn = DBConnection.createConnection();
                PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Users user = new Users();
                    user.setUser_id(rs.getInt("user_id"));
                    user.setUser_name(rs.getString("user_name"));
                    user.setPassword(rs.getString("password"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setFaculty(rs.getString("faculty"));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Users getUserByEmail(String email) {
        if (email == null) {
            return null;
        }
        String query = "SELECT user_id, user_name, password, email, role, status, faculty "
                + "FROM Users WHERE email = ?";
        try (Connection conn = DBConnection.createConnection();
                PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Users user = new Users();
                    user.setUser_id(rs.getInt("user_id"));
                    user.setUser_name(rs.getString("user_name"));
                    user.setPassword(rs.getString("password"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setFaculty(rs.getString("faculty"));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Map<String, String> getUserProfile(int userId) {
        Map<String, String> profile = new HashMap<>();
            
            String sql = "SELECT user_name, role, faculty, email FROM Users WHERE user_id = ?";
            try (Connection conn = DBConnection.createConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, userId);
                ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                profile.put("user_name", rs.getString("user_name"));
                profile.put("role", rs.getString("role"));
                profile.put("faculty", rs.getString("faculty"));
                profile.put("email", rs.getString("email"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return profile;
    }
}
