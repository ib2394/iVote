package bean;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordHashing {

    public static String hashPassword(String password) {
        try {
            // Create an instance of MessageDigest with SHA-256 algorithm
            MessageDigest digest = MessageDigest.getInstance("SHA-256");

            // Update the MessageDigest with the password bytes
            byte[] hashBytes = digest.digest(password.getBytes());

            // Convert the byte array to a hex string
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                hexString.append(String.format("%02x", b)); // Convert each byte to a hex value
            }

            // Return the hex string as the hashed password
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            // Handle exception if SHA-256 is not available
            e.printStackTrace();
            return null;
        }
    }
}

