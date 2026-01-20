<%-- 
    Document   : resultPage
    Created on : Jan 19, 2026, 12:30:02 PM
    Author     : Victus
--%>

<%@page import="java.util.List"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
    <head>
        <title>Election Results</title>
        <style>
            .bar {
                background-color: #4CAF50;
                height: 20px;
                margin: 5px 0;
            }
            .label {
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <h2>Election Results</h2>

        <% if (request.getAttribute("results") != null) { %>
        <ul>
            <% for (bean.Candidate cr : (List<bean.Candidate>) request.getAttribute("results")) { %>
                <li>
                    <span class="label"><%= cr.getCandidateName() %></span> — 
                    <%= String.format("%.1f", cr.getPercentage()) %>% 
                    <div class="bar" style="width: <%= Math.max(1, cr.getPercentage()) %>%;"></div>
                </li>
                <% } %>
        </ul>
        <p><strong>Total Votes:</strong> <%= request.getAttribute("totalVotes") %></p>
        <% } else { %>
        <p>No results available.</p>
        <% } %>

        <a href="homepage.html">Back to Homepage</a>
    </body>
</html>