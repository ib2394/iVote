/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package bean;

/**
 *
 * @author Victus
 */
public class Position {
    private int position_id;
    private String position_name;
    private int election_id;        // Foreign key ID
    private Election election;     // Optional: Full Election object reference

    // No-argument constructor
    public Position() {
    }

    // Constructor without ID
    public Position(String position_name, int election_id) {
        this.position_name = position_name;
        this.election_id = election_id;
    }

    // Constructor with all fields
    public Position(int position_id, String position_name, int election_id) {
        this.position_id = position_id;
        this.position_name = position_name;
        this.election_id = election_id;
    }

    // Getters and Setters
    public int getPosition_id() {
        return position_id;
    }

    public void setPosition_id(int position_id) {
        this.position_id = position_id;
    }

    public String getPosition_name() {
        return position_name;
    }

    public void setPosition_name(String position_name) {
        this.position_name = position_name;
    }

    public int getElection_id() {
        return election_id;
    }

    public void setElection_id(int election_id) {
        this.election_id = election_id;
    }

    public Election getElection() {
        return election;
    }

    public void setElection(Election election) {
        this.election = election;
        if (election != null) {
            this.election_id = election.getElection_id();
        }
    }

    @Override
    public String toString() {
        return "Position{" + 
                "position_id=" + position_id + 
                ", position_name='" + position_name + '\'' + 
                ", election_id=" + election_id + 
                ", election=" + (election != null ? election.getElection_name() : "null") + 
                '}';
    }
}
