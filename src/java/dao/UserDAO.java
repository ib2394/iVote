/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

import bean.Users;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public Users authenticateUser(String email, String password) {
        Users user = null;
        String query = "SELECT user_id, user_name, password, email, role, status " +
                       "FROM Users WHERE email = ? AND password = ?";

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
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    public boolean registerUser(Users user) {
        String query = "INSERT INTO Users (user_name, password, email, role, status) " +
                       "VALUES (?, ?, ?, ?, ?)";

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

    // OPTIONAL: update status (since your bean has status)
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
}
