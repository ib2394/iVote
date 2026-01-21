/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import bean.Users;
import dao.CandidateDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class DeleteCandidateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Only admins can delete candidates (support new + legacy auth)
        Users currentUser = (Users) session.getAttribute("user");
        String legacyRole = (String) session.getAttribute("role"); // admin/student/lecturer

        if (currentUser == null) {
            if (legacyRole == null || !"admin".equalsIgnoreCase(legacyRole)) {
                response.sendRedirect("login.jsp");
                return;
            }
        } else {
            if (!"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect("login.jsp");
                return;
            }
        }
        
        // Get candidate ID from request
        String candidateIdStr = request.getParameter("candidateId");
        if (candidateIdStr == null || candidateIdStr.isEmpty()) {
            session.setAttribute("errorMessage", "No candidate ID provided!");
            response.sendRedirect("CandidateListServlet");
            return;
        }
        
        try {
            int candidateId = Integer.parseInt(candidateIdStr);
            CandidateDAO candidateDAO = new CandidateDAO();
            
            boolean result = candidateDAO.deleteCandidate(candidateId);
            
            if (result) {
                session.setAttribute("successMessage", "Candidate deleted successfully!");
            } else {
                session.setAttribute("errorMessage", "Failed to delete candidate. Please try again.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid candidate ID!");
        }
        
        // Refresh candidate list page
        response.sendRedirect("viewCandidates.jsp");
    }
}