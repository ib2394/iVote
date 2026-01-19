/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.java.bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class Vote implements Serializable {
    private int voteId;
    private int voterId;
    private int candidateId;
    private Timestamp voteTime;
    private String ipAddress;
    
    // Getters and Setters
    public int getVoteId() { return voteId; }
    public void setVoteId(int voteId) { this.voteId = voteId; }
    
    public int getVoterId() { return voterId; }
    public void setVoterId(int voterId) { this.voterId = voterId; }
    
    public int getCandidateId() { return candidateId; }
    public void setCandidateId(int candidateId) { this.candidateId = candidateId; }
    
    public Timestamp getVoteTime() { return voteTime; }
    public void setVoteTime(Timestamp voteTime) { this.voteTime = voteTime; }
    
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
}