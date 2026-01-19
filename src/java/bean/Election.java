/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.java.bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class Election implements Serializable {
    private int settingId;
    private String electionName;
    private Timestamp startDate;
    private Timestamp endDate;
    private boolean isActive;
    private int createdBy;

    public int getSettingId() { return settingId; }
    public void setSettingId(int settingId) { this.settingId = settingId; }
    
    public String getElectionName() { return electionName; }
    public void setElectionName(String electionName) { this.electionName = electionName; }
    
    public Timestamp getStartDate() { return startDate; }
    public void setStartDate(Timestamp startDate) { this.startDate = startDate; }
    
    public Timestamp getEndDate() { return endDate; }
    public void setEndDate(Timestamp endDate) { this.endDate = endDate; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean isActive) { this.isActive = isActive; }
    
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
}