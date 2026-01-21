/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import bean.Position;
import bean.Users;
import dao.ElectionDAO;
import dao.PositionDAO;
import dao.VoteDAO;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;

public class VotingServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Users user = (session != null) ? (Users) session.getAttribute("user") : null;
        String legacyRole = (session != null) ? (String) session.getAttribute("role") : null;
        String legacyUserName = (session != null) ? (String) session.getAttribute("userName") : null;

        if (user == null) {
            // legacy login path (must map to a real Users row to vote)
            if (legacyRole == null || !"student".equalsIgnoreCase(legacyRole)) {
                response.sendRedirect("login.jsp");
                return;
            }
            if (legacyUserName != null && legacyUserName.indexOf("@") > 0) {
                dao.UserDAO userDAO = new dao.UserDAO();
                Users maybe = userDAO.getUserByEmail(legacyUserName);
                if (maybe != null) {
                    user = maybe;
                    session.setAttribute("user", user);
                }
            }
        }

        if (user == null || !"STUDENT".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String candidateParam = request.getParameter("candidateId");
        String positionParam = request.getParameter("positionId");
        if (candidateParam == null || positionParam == null) {
            response.sendRedirect("VotingPage.jsp?error=missingParams");
            return;
        }

        int candidateId = Integer.parseInt(candidateParam);
        int positionId = Integer.parseInt(positionParam);

        PositionDAO positionDAO = new PositionDAO();
        Position position = positionDAO.getPositionById(positionId);
        if (position == null) {
            response.sendRedirect("VotingPage.jsp?error=invalidPosition");
            return;
        }

        ElectionDAO electionDAO = new ElectionDAO();
        if (!electionDAO.isActive(position.getElection_id())) {
            response.sendRedirect("VotingPage.jsp?error=electionClosed");
            return;
        }

        VoteDAO voteDAO = new VoteDAO();
        if (voteDAO.hasVotedForPosition(user.getUser_id(), positionId)) {
            response.sendRedirect("VotingPage.jsp?error=alreadyVoted");
            return;
        }

        boolean success = voteDAO.castVote(user.getUser_id(), candidateId, positionId);
        if (success) {
            response.sendRedirect("VotingPage.jsp?vote=success");
        } else {
            response.sendRedirect("VotingPage.jsp?vote=failed");
        }
    }
}