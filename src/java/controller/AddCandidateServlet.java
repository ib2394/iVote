package controller;

import bean.Candidates;
import bean.Users;
import dao.CandidateDAO;
import dao.PositionDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AddCandidateServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check if admin is logged in
        Users currentUser = (Users) session.getAttribute("user");
        String legacyRole = (String) session.getAttribute("role");
        String legacyUserName = (String) session.getAttribute("userName");

        if (currentUser == null) {
            if (legacyRole == null || !"admin".equalsIgnoreCase(legacyRole)) {
                response.sendRedirect("login.jsp");
                return;
            }
            if (legacyUserName != null && legacyUserName.indexOf("@") > 0) {
                dao.UserDAO userDAO = new dao.UserDAO();
                Users maybe = userDAO.getUserByEmail(legacyUserName);
                if (maybe != null) {
                    currentUser = maybe;
                    session.setAttribute("user", currentUser);
                }
            }
        }

        if (currentUser != null && !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get form parameters
        String userIdStr = request.getParameter("userId");
        String positionIdStr = request.getParameter("positionId");
        String manifesto = request.getParameter("manifesto");
        
        // Validate inputs
        if (userIdStr == null || userIdStr.trim().isEmpty() || 
            positionIdStr == null || positionIdStr.trim().isEmpty() ||
            manifesto == null || manifesto.trim().isEmpty()) {
            
            session.setAttribute("errorMessage", "Please fill in all required fields!");
            response.sendRedirect("addCandidate.jsp");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            int positionId = Integer.parseInt(positionIdStr);
            
            // Validate position exists
            PositionDAO positionDAO = new PositionDAO();
            if (positionDAO.getPositionById(positionId) == null) {
                session.setAttribute("errorMessage", "Invalid position selected.");
                response.sendRedirect("addCandidate.jsp");
                return;
            }
            
            // Create Candidate object
            Candidates candidate = new Candidates();
            candidate.setUserId(userId);
            candidate.setPosition_id(positionId);
            candidate.setManifesto(manifesto.trim());
            
            // Call DAO to insert into database
            CandidateDAO candidateDAO = new CandidateDAO();
            boolean success = candidateDAO.addCandidate(candidate);
            
            // Handle result
            if (success) {
                session.setAttribute("successMessage", "Candidate added successfully!");
                response.sendRedirect("CandidateListServlet");
            } else {
                session.setAttribute("errorMessage", "Failed to add candidate. Please check if user exists and is not already a candidate for this position.");
                response.sendRedirect("addCandidate.jsp");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid User ID or Position ID format!");
            response.sendRedirect("addCandidate.jsp");
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("addCandidate.jsp");
        }
    }
}