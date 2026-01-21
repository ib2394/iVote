/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import bean.Candidates;
import bean.Users;
import dao.CandidateDAO;
import dao.PositionDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AddCandidateServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Only admins can add candidates
        Users currentUser = (Users) session.getAttribute("user");
        if (currentUser == null || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = Integer.parseInt(request.getParameter("userId"));
        int positionId = Integer.parseInt(request.getParameter("positionId"));
        String manifesto = request.getParameter("manifesto");

        if (manifesto == null || manifesto.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Manifesto is required.");
            response.sendRedirect("adminDashboard.jsp");
            return;
        }

        PositionDAO positionDAO = new PositionDAO();
        if (positionDAO.getPositionById(positionId) == null) {
            session.setAttribute("errorMessage", "Invalid position selected.");
            response.sendRedirect("adminDashboard.jsp");
            return;
        }

        Candidates candidate = new Candidates(userId, positionId, manifesto.trim());
        CandidateDAO candidateDAO = new CandidateDAO();
        boolean result = candidateDAO.addCandidate(candidate);

        if (result) {
            session.setAttribute("successMessage", "Candidate added successfully.");
        } else {
            session.setAttribute("errorMessage", "Failed to add candidate. Please retry.");
        }
        response.sendRedirect("adminDashboard.jsp");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("addCandidate.jsp");
    }
}