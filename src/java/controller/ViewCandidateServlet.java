package controller;

import dao.CandidateDAO;
import bean.Candidates;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;

public class ViewCandidateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Fetch all candidates using the DAO
        CandidateDAO candidateDAO = new CandidateDAO();
        List<Candidates> candidatesList = candidateDAO.getAllCandidates();

        // Set the candidates list as a request attribute
        request.setAttribute("candidates", candidatesList);

        // Forward the request to the JSP page
        request.getRequestDispatcher("viewCandidates.jsp").forward(request, response);
    }
}
