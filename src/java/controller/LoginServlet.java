/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import bean.Users;
import dao.UserDAO;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        UserDAO userDAO = new UserDAO();
        Users user = userDAO.authenticateUser(email, password);

        if (user == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("adminDashboard.jsp");
        } else if ("STUDENT".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("VotingPage.jsp");
        } else {
            response.sendRedirect("index.html");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}
