package controller;

import bean.Candidates;
import dao.CandidateDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.*;
import javax.servlet.http.*;

public class CandidateListServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check for session messages
        String successMessage = (String) session.getAttribute("successMessage");
        String errorMessage = (String) session.getAttribute("errorMessage");
        
        if (successMessage != null) {
            request.setAttribute("message", successMessage);
            session.removeAttribute("successMessage");
        }
        
        if (errorMessage != null) {
            request.setAttribute("error", errorMessage);
            session.removeAttribute("errorMessage");
        }
        
        CandidateDAO candidateDAO = new CandidateDAO();
        List<Candidates> candidates = candidateDAO.getAllCandidates();

        request.setAttribute("candidates", candidates);
        RequestDispatcher rd = request.getRequestDispatcher("viewCandidates.jsp");
        rd.forward(request, response);
    }
}