<%-- 
    Document   : resultPage
    Created on : Jan 19, 2026, 12:30:02 PM
    Author     : Victus
--%>

<%@page import="java.util.List"%>
<%@page import="bean.CandidateResult"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>Election Results</title>
    <style>
        .bar { background:#4CAF50; height:20px; margin:5px 0; }
        .label { font-weight:bold; }
        .card { border:1px solid #ddd; padding:10px; margin:10px 0; border-radius:8px; }
        .muted { color:#666; font-size:13px; }
    </style>
</head>
<body>
<h2>Election Results</h2>

<%
    List<CandidateResult> results = (List<CandidateResult>) request.getAttribute("results");
%>

<% if (results != null && !results.isEmpty()) { %>
    <p><strong>Total Votes:</strong> <%= request.getAttribute("totalVotes") %></p>

    <% for (CandidateResult cr : results) { %>
        <div class="card">
            <div class="label"><%= cr.getUser_name() %></div>
            <div class="muted">
                Position: <%= cr.getPosition_name() %><br/>
                Votes: <%= cr.getVote_count() %>
            </div>

            <div>
                <%= String.format("%.1f", cr.getPercentage()) %>%
                <div class="bar" style="width:<%= Math.max(1, cr.getPercentage()) %>%;"></div>
            </div>

            <p><%= cr.getManifesto() %></p>
        </div>
    <% } %>

<% } else { %>
    <p>No results available.</p>
<% } %>

<a href="homepage.html">Back to Homepage</a>
</body>
</html>
