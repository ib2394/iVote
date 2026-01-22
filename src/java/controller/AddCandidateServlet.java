package controller;

import dao.CandidateDAO;
import bean.Candidates;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AddCandidateServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            // REMOVED: String user_idStr = request.getParameter("user_id");
            String election_idStr = request.getParameter("election_id");
            String candidateName = request.getParameter("candidate_name");
            String faculty = request.getParameter("faculty");
            String email = request.getParameter("email");
            String manifesto = request.getParameter("manifesto");
            
            System.out.println("AddCandidateServlet: Received data - " +
                    "election_id: " + election_idStr + 
                    ", candidate_name: " + candidateName);
            
            // REMOVED: user_id validation
            if (election_idStr == null || election_idStr.isEmpty() ||
                candidateName == null || candidateName.isEmpty() ||
                faculty == null || faculty.isEmpty() ||
                email == null || email.isEmpty() ||
                manifesto == null || manifesto.isEmpty()) {
                
                session.setAttribute("errorMessage", "All fields are required!");
                response.sendRedirect("addCandidate.jsp");
                return;
            }
            
            // REMOVED: int user_id = Integer.parseInt(user_idStr);
            int election_id = Integer.parseInt(election_idStr);
            
            Candidates candidate = new Candidates();
            // REMOVED: candidate.setUser_id(user_id);
            candidate.setElection_id(election_id);
            candidate.setCandidate_name(candidateName);
            candidate.setFaculty(faculty);
            candidate.setEmail(email);
            candidate.setManifesto(manifesto);
            
            CandidateDAO candidateDAO = new CandidateDAO();
            boolean success = candidateDAO.addCandidate(candidate);
            
            if (success) {
                System.out.println("AddCandidateServlet: Candidate added successfully");
                session.setAttribute("successMessage", "Candidate registered successfully!");
            } else {
                System.out.println("AddCandidateServlet: Failed to add candidate");
                session.setAttribute("errorMessage", "Failed to register candidate. Please try again.");
            }
            
            response.sendRedirect("addCandidate.jsp");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid election ID format!");
            response.sendRedirect("addCandidate.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "System error: " + e.getMessage());
            response.sendRedirect("addCandidate.jsp");
        }
    }
}