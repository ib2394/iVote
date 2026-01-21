/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package bean;

import java.io.Serializable;
import java.sql.Date;

public class Vote implements Serializable {

    private int vote_id;
    private int user_id;//user who vote
    private int candidate_id;
    private int position_id;
    private Date vote_time;

    // No-argument constructor
    public Vote() {
    }

    // Constructor without ID
    public Vote(int user_id, int candidate_id, int position_id, Date vote_time) {
        this.user_id = user_id;
        this.candidate_id = candidate_id;
        this.position_id = position_id;
        this.vote_time = vote_time;
    }

    // Getters and Setters
    public int getVote_id() {
        return vote_id;
    }

    public void setVote_id(int vote_id) {
        this.vote_id = vote_id;
    }

    public int getUser_id() {
        return user_id;
    }

    public void setUser_id(int user_id) {
        this.user_id = user_id;
    }

    public int getCandidate_id() {
        return candidate_id;
    }

    public void setCandidate_id(int candidate_id) {
        this.candidate_id = candidate_id;
    }

    public int getPosition_id() {
        return position_id;
    }

    public void setPosition_id(int position_id) {
        this.position_id = position_id;
    }

    public Date getVote_time() {
        return vote_time;
    }

    public void setVote_time(Date vote_time) {
        this.vote_time = vote_time;
    }
}
