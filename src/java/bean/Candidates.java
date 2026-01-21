/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package bean;

import java.io.Serializable;

public class Candidates implements Serializable {

    private int candidate_id;
    private int user_id;
    private int position_id;
    private String manifesto;

    // No-argument constructor (required)
    public Candidates() {
    }

    // Constructor with fields
    public Candidates(int user_id, int position_id, String manifesto) {
        this.user_id = user_id;
        this.position_id = position_id;
        this.manifesto = manifesto;
    }

    // Getters and Setters
    public int getCandidate_id() {
        return candidate_id;
    }

    public void setCandidate_id(int candidate_id) {
        this.candidate_id = candidate_id;
    }

    public int getUserId() {
        return user_id;
    }
    
    public void setUserId(int userId) {
        this.user_id = userId;
    }

    public int getPosition_id() {
        return position_id;
    }

    public void setPosition_id(int position_id) {
        this.position_id = position_id;
    }

    public String getManifesto() {
        return manifesto;
    }

    public void setManifesto(String manifesto) {
        this.manifesto = manifesto;
    }
}

