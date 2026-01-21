package controller;

import dao.ResultDAO;
import bean.CandidateResult;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class ResultServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Retrieve election_id from the request URL
        String election_idStr = request.getParameter("election_id");

        if (election_idStr == null || election_idStr.trim().isEmpty()) {
            response.sendRedirect("errorPage.jsp");
            return;
        }

        // Convert the election_id from string to integer
        int electionId = Integer.parseInt(election_idStr);  // Correctly using electionId

        // Get results and total votes from the DAO
        ResultDAO dao = new ResultDAO();
        List<CandidateResult> results = dao.getResultsByElectionId(electionId);  // Corrected to use electionId
        int totalVotes = dao.getTotalVotesByElectionId(electionId);  // Corrected to use electionId

        // Set attributes for the results JSP
        request.setAttribute("results", results);
        request.setAttribute("totalVotes", totalVotes);
        request.setAttribute("electionId", electionId);

        // Forward to the resultPage.jsp
        request.getRequestDispatcher("resultPage.jsp").forward(request, response);  // Forward results to JSP
    }
}
