package controller;

import bean.CandidateView;
import dao.CandidateDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CandidateListServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        CandidateDAO candidateDAO = new CandidateDAO();
        List<CandidateView> candidates = candidateDAO.getAllCandidateViews();

        request.setAttribute("candidates", candidates);
        RequestDispatcher rd = request.getRequestDispatcher("viewCandidates.jsp");
        rd.forward(request, response);
    }
}