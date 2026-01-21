/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package bean;

import java.io.Serializable;
import java.sql.Date;

public class Election implements Serializable {
    private int election_id;        // Matches election_id in table
    private String election_name;   // Matches election_name in table
    private Date start_date;        // Matches start_date (DATE type, not TIMESTAMP)
    private Date end_date;          // Matches end_date (DATE type, not TIMESTAMP)
    private String status;         // Matches status in table (VARCHAR(20))

    // No-argument constructor
    public Election() {
    }

    // Constructor with all fields except ID
    public Election(String election_name, Date start_date, Date end_date, String status) {
        this.election_name = election_name;
        this.start_date = start_date;
        this.end_date = end_date;
        this.status = status;
    }

    // Constructor with all fields
    public Election(int election_id, String election_name, Date start_date, Date end_date, String status) {
        this.election_id = election_id;
        this.election_name = election_name;
        this.start_date = start_date;
        this.end_date = end_date;
        this.status = status;
    }

    // Getters and Setters
    public int getElection_id() {
        return election_id;
    }

    public void setElection_id(int election_id) {
        this.election_id = election_id;
    }

    public String getElection_name() {
        return election_name;
    }

    public void setElection_name(String election_name) {
        this.election_name = election_name;
    }

    public Date getStart_date() {
        return start_date;
    }

    public void setStart_date(Date start_date) {
        this.start_date = start_date;
    }

    public Date getEnd_date() {
        return end_date;
    }

    public void setEnd_date(Date end_date) {
        this.end_date = end_date;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Election{" + 
                "election_id=" + election_id + 
                ", election_name='" + election_name + '\'' + 
                ", start_date=" + start_date + 
                ", end_date=" + end_date + 
                ", status='" + status + '\'' + 
                '}';
    }
}