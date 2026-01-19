/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author Victus
 */
public class DBConnection {
    
    // Database connection parameters
    private static final String URL = "jdbc:derby://localhost:1527/iVoteDB";
    private static final String USER = "app";
    private static final String PASSWORD = "app";
    
    /**
     * Creates and returns a connection to the Derby 'customers' database
     * @return Connection object to the database
     * @throws SQLException if connection fails
     */
    public static Connection createConnection() throws SQLException {
        try {
            // Load Derby Client Driver (optional in newer Java versions, but safe to include)
            Class.forName("org.apache.derby.jdbc.ClientDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Derby Client Driver not found", e);
        }
        
        // Establish and return connection
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}