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
            String electionId = request.getParameter("election_id");  // Retrieve the election_id from URL parameters
            if (electionId == null || electionId.trim().isEmpty()) {
                out.println("<p style='color:red;'>Missing election ID.</p>");
                return;
            }

            List<CandidateResult> results = (List<CandidateResult>) request.getAttribute("results");
        %>

        <% if (results != null && !results.isEmpty()) {%>
        <p><strong>Total Votes in Election <%= electionId%>:</strong> <%= request.getAttribute("totalVotes")%></p>

        <% for (CandidateResult cr : results) {%>
        <div class="card">
            <div class="label"><%= cr.getUser_name()%></div>
            <div class="muted">
                Votes: <%= cr.getVote_count()%>
            </div>

            <div>
                <%= String.format("%.1f", cr.getPercentage())%>%
                <div class="bar" style="width:<%= Math.max(1, cr.getPercentage())%>%;"></div>
            </div>

            <p><%= cr.getManifesto()%></p>
        </div>
        <% } %>

        <% } else {%>
        <p>No results available for election <%= electionId%>.</p>
        <% }%>

        <a href="homepage.html">Back to Homepage</a>
    </body>
</html>
