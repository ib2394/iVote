package controller;

import dao.CandidateDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class DeleteCandidateServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            // Try "id" parameter first, then "candidate_id" for backward compatibility
            String candidateIdStr = request.getParameter("id");
            if (candidateIdStr == null || candidateIdStr.isEmpty()) {
                candidateIdStr = request.getParameter("candidate_id");
            }
            
            if (candidateIdStr == null || candidateIdStr.isEmpty()) {
                session.setAttribute("errorMessage", "Candidate ID is required!");
                response.sendRedirect("CandidateListServlet");
                return;
            }
            
            int candidateId = Integer.parseInt(candidateIdStr);
            
            CandidateDAO candidateDAO = new CandidateDAO();
            boolean success = candidateDAO.deleteCandidate(candidateId);
            
            if (success) {
                System.out.println("DeleteCandidateServlet: Candidate " + candidateId + " deleted successfully");
                session.setAttribute("successMessage", "Candidate deleted successfully!");
            } else {
                System.out.println("DeleteCandidateServlet: Failed to delete candidate " + candidateId);
                session.setAttribute("errorMessage", "Failed to delete candidate. It may have associated votes.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid candidate ID format!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "System error: " + e.getMessage());
        }
        
        response.sendRedirect("CandidateListServlet");
    }
}