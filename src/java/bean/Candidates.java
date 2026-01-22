package bean;

public class Candidates {
    private int candidate_id;
    private String candidate_name;
    private String faculty;
    private String email;
    private String manifesto;
    private int election_id;
    
    // Constructors
    public Candidates() {}
    
    // Getters and Setters
    public int getCandidate_id() { 
        return candidate_id; 
    }
    public void setCandidate_id(int candidate_id) { 
        this.candidate_id = candidate_id; 
    }
    
    public String getCandidate_name() { 
        return candidate_name; 
    }
    public void setCandidate_name(String candidate_name) { 
        this.candidate_name = candidate_name; 
    }
    
    public String getFaculty() { 
        return faculty; 
    }
    public void setFaculty(String faculty) { 
        this.faculty = faculty; 
    }
    
    public String getEmail() { 
        return email; 
    }
    public void setEmail(String email) { 
        this.email = email; 
    }
    
    public String getManifesto() { 
        return manifesto; 
    }
    public void setManifesto(String manifesto) { 
        this.manifesto = manifesto; 
    }
    
    public int getElection_id() { 
        return election_id; 
    } 
    public void setElection_id(int election_id) { 
        this.election_id = election_id; 
    } 
    
    @Override
    public String toString() {
        return "Candidates{" +
                "candidate_id=" + candidate_id +
                ", candidate_name='" + candidate_name + '\'' +
                ", faculty='" + faculty + '\'' +
                ", email='" + email + '\'' +
                ", manifesto='" + manifesto + '\'' +
                ", election_id=" + election_id +
                '}';
    }
}