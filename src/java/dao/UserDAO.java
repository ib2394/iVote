/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

import com.java.bean.User;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    
    public User authenticateUser(String email, String password) {
        User user = null;
        String query = "SELECT * FROM Users WHERE email = ? AND password = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setFaculty(rs.getString("faculty"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setProfilePic(rs.getString("profile_pic"));
                user.setHasVoted(rs.getBoolean("has_voted"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }
    
    public boolean registerUser(User user) {
        String query = "INSERT INTO Users (full_name, email, faculty, password, role) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, user.getFullName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getFaculty());
            pstmt.setString(4, user.getPassword());
            pstmt.setString(5, user.getRole());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateVoteStatus(int userId) {
        String query = "UPDATE Users SET has_voted = TRUE WHERE user_id = ?";
        
        try (Connection conn = DBConnection.createConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setInt(1, userId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
