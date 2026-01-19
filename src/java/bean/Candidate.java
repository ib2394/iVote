/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.java.bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class Candidate implements Serializable {
    private int candidateId;
    private int userId;
    private String candidateName;
    private String email;
    private String program;
    private String faculty;
    private String description;
    private String photoUrl;
    private Timestamp nominationDate;
    private int voteCount;
    
    // Constructors
    public Candidate() {}
    
    public Candidate(String candidateName, String email, String program, String faculty, String description) {
        this.candidateName = candidateName;
        this.email = email;
        this.program = program;
        this.faculty = faculty;
        this.description = description;
    }
    
    // Getters and Setters
    public int getCandidateId() { return candidateId; }
    public void setCandidateId(int candidateId) { this.candidateId = candidateId; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getCandidateName() { return candidateName; }
    public void setCandidateName(String candidateName) { this.candidateName = candidateName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }
    
    public String getFaculty() { return faculty; }
    public void setFaculty(String faculty) { this.faculty = faculty; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    
    public Timestamp getNominationDate() { return nominationDate; }
    public void setNominationDate(Timestamp nominationDate) { this.nominationDate = nominationDate; }
    
    public int getVoteCount() { return voteCount; }
    public void setVoteCount(int voteCount) { this.voteCount = voteCount; }
}
