/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import com.java.bean.User;
import dao.VoteDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

public class VotingServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        int candidateId = Integer.parseInt(request.getParameter("candidateId"));
        String ipAddress = request.getRemoteAddr();
        
        VoteDAO voteDAO = new VoteDAO();
        
        if (voteDAO.castVote(user.getUserId(), candidateId, ipAddress)) {
            // Update user object in session
            user.setHasVoted(true);
            session.setAttribute("user", user);
            
            response.sendRedirect("votingPage.jsp?vote=success");
        } else {
            response.sendRedirect("votingPage.jsp?vote=failed");
        }
    }
}