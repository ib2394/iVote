package bean;

import java.io.Serializable;

public class CandidateView implements Serializable {
    private int candidate_id;
    private int user_id;
    private String user_name;
    private String candidate_name;
    private String faculty;
    private String email;
    private String manifesto;
    private int vote_count;
    private int election_id;     
    private String election_name;

    public CandidateView() {
        this.election_id = 0;
        this.vote_count = 0;
    }
    
    //constructor
    public CandidateView(int candidate_id, int user_id, String user_name, 
                        String candidate_name, String faculty, String email, 
                        String manifesto, int vote_count, int election_id, 
                        String election_name) {
        this.candidate_id = candidate_id;
        this.user_id = user_id;
        this.user_name = user_name;
        this.candidate_name = candidate_name;
        this.faculty = faculty;
        this.email = email;
        this.manifesto = manifesto;
        this.vote_count = vote_count;
        this.election_id = election_id;
        this.election_name = election_name;
    }
    
    // Getters and Setters
    public int getCandidate_id() { return candidate_id; }
    public void setCandidate_id(int candidate_id) { this.candidate_id = candidate_id; }
    
    public int getUser_id() { return user_id; }
    public void setUser_id(int user_id) { this.user_id = user_id; }
    
    public String getUser_name() { return user_name; }
    public void setUser_name(String user_name) { this.user_name = user_name; }
    
    public String getCandidate_name() { return candidate_name; }
    public void setCandidate_name(String candidate_name) { this.candidate_name = candidate_name; }
    
    public String getFaculty() { return faculty; }
    public void setFaculty(String faculty) { this.faculty = faculty; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getManifesto() { return manifesto; }
    public void setManifesto(String manifesto) { this.manifesto = manifesto; }
    
    public int getVote_count() { return vote_count; }
    public void setVote_count(int vote_count) { this.vote_count = vote_count; }
    
    // New getters and setters
    public int getElection_id() { return election_id; }
    public void setElection_id(int election_id) { this.election_id = election_id; }
    
    public String getElection_name() { return election_name; }
    public void setElection_name(String election_name) { this.election_name = election_name; }
    
    @Override
    public String toString() {
        return "CandidateView{" + 
                "candidate_id=" + candidate_id + 
                ", user_id=" + user_id + 
                ", user_name='" + user_name + '\'' + 
                ", candidate_name='" + candidate_name + '\'' + 
                ", faculty='" + faculty + '\'' + 
                ", email='" + email + '\'' + 
                ", manifesto='" + (manifesto != null && manifesto.length() > 20 ? 
                                  manifesto.substring(0, 20) + "..." : manifesto) + '\'' + 
                ", vote_count=" + vote_count + 
                ", election_id=" + election_id + 
                ", election_name='" + election_name +  
                '}';
    }
}