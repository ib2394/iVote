/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import dao.CandidateDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/DeleteCandidateServlet")
public class DeleteCandidateServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check if admin is logged in
        String adminID = (String) session.getAttribute("adminID");
        if (adminID == null) {
            response.sendRedirect("adminLogin.jsp");
            return;
        }
        
        // Get candidate ID from request
        String candidateIdStr = request.getParameter("id");
        if (candidateIdStr == null || candidateIdStr.isEmpty()) {
            session.setAttribute("errorMessage", "No candidate ID provided!");
            response.sendRedirect("adminDashboard.jsp");
            return;
        }
        
        try {
            int candidateId = Integer.parseInt(candidateIdStr);
            CandidateDAO candidateDAO = new CandidateDAO();
            
            // Assuming deleteCandidate returns String like "SUCCESS" or "FAILED"
            boolean result = candidateDAO.deleteCandidate(candidateId);
            
            if ("SUCCESS".equals(result)) {
                session.setAttribute("successMessage", "Candidate deleted successfully!");
            } else if ("FAILED".equals(result)) {
                session.setAttribute("errorMessage", "Failed to delete candidate. Please try again.");
            } else {
                session.setAttribute("errorMessage", "Delete operation failed: " + result);
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid candidate ID!");
        }
        
        response.sendRedirect("adminDashboard.jsp");
    }
}