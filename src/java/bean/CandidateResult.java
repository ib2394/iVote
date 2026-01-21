/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package bean;

import java.io.Serializable;

public class CandidateResult implements Serializable {
    private int candidate_id;
    private int user_id;
    private int position_id;
    private String user_name;      // from USERS
    private String email;         // from USERS (optional)
    private String position_name;  // from POSITION
    private String manifesto;     // from CANDIDATES
    private int vote_count;        // from VOTES
    private double percentage;    // calculated

    public int getCandidate_id() { return candidate_id; }
    public void setCandidate_id(int candidate_id) { this.candidate_id = candidate_id; }

    public int getUser_id() { return user_id; }
    public void setUser_id(int user_id) { this.user_id = user_id; }

    public int getPosition_id() { return position_id; }
    public void setPosition_id(int position_id) { this.position_id = position_id; }

    public String getUser_name() { return user_name; }
    public void setUser_name(String user_name) { this.user_name = user_name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPosition_name() { return position_name; }
    public void setPosition_name(String position_name) { this.position_name = position_name; }

    public String getManifesto() { return manifesto; }
    public void setManifesto(String manifesto) { this.manifesto = manifesto; }

    public int getVote_count() { return vote_count; }
    public void setVoteCount(int vote_count) { this.vote_count = vote_count; }

    public double getPercentage() { return percentage; }
    public void setPercentage(double percentage) { this.percentage = percentage; }
}

