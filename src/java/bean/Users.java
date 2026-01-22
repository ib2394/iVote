/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package bean;

import java.io.Serializable;

public class Users implements Serializable {

    private int user_id;
    private String user_name;
    private String password;
    private String email;
    private String role;
    private String status;
    private String faculty;

    // No-argument constructor (required for JavaBean)
    public Users() {
    }

    // Constructor without ID (auto-generated)
    public Users(String user_name, String password, String email, String role, String status, String faculty) {
        this.user_name = user_name;
        this.password = password;
        this.email = email;
        this.role = role;
        this.status = status;
        this.faculty = faculty;
    }

    // Constructor with all fields
    public Users(int user_id, String user_name, String password, String email, String role, String status, String faculty) {
        this.user_id = user_id;
        this.user_name = user_name;
        this.password = password;
        this.email = email;
        this.role = role;
        this.status = status;
        this.faculty = faculty;
    }

    // Getters and Setters
    public int getUser_id() {
        return user_id;
    }

    public void setUser_id(int user_id) {
        this.user_id = user_id;
    }

    public String getUser_name() {
        return user_name;
    }

    public void setUser_name(String user_name) {
        this.user_name = user_name;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getFaculty() {
        return faculty;
    }

    public void setFaculty(String faculty) {
        this.faculty = faculty;
    }

    @Override
    public String toString() {
        return "Users{" + 
                "user_id=" + user_id + 
                ", user_name='" + user_name + '\'' + 
                ", email='" + email + '\'' + 
                ", role='" + role + '\'' + 
                ", status='" + status + '\'' + 
                ", faculty='" + faculty + '\'' + 
                '}';
    }

    public void add(Users users) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
}