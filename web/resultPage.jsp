<%@page import="java.util.List"%>
<%@page import="bean.CandidateResult"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Election Results</title>
        <style>
            /* General Styles */
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #f5f5f5;
                color: #333;
                margin: 0;
                padding: 0;
            }

            h2 {
                text-align: center;
                color: #6a0dad;
                margin-top: 50px;
                font-size: 2.5rem;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 20px;
            }

            .back-link {
                display: inline-block;
                margin-top: 20px;
                font-size: 1rem;
                text-decoration: none;
                color: #3498db;
                border: 1px solid #3498db;
                padding: 10px 20px;
                border-radius: 5px;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .back-link:hover {
                background-color: #3498db;
                color: white;
            }

            /* Card Styles */
            .card {
                background-color: white;
                border-radius: 8px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                margin: 20px 0;
                padding: 20px;
                display: flex;
                flex-direction: column;
                align-items: center;
                transition: transform 0.3s ease;
            }

            .card:hover {
                transform: translateY(-5px);
            }

            .candidate-name {
                font-size: 1.5rem;
                color: #333;
                font-weight: 600;
                margin-bottom: 10px;
            }

            .muted {
                font-size: 1rem;
                color: #888;
            }

            .bar {
                width: 100%;
                background: #f2f2f2;
                height: 20px;
                margin: 10px 0;
                border-radius: 10px;
            }

            .bar-fill {
                background-color: #4CAF50;
                height: 100%;
                border-radius: 10px;
            }

            .percentage {
                font-size: 1.2rem;
                font-weight: 600;
                color: #4CAF50;
            }

            /* Layout Styles */
            .results-container {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 20px;
                margin-top: 40px;
            }

            .card-header {
                font-size: 1.3rem;
                color: #333;
                font-weight: 600;
                margin-bottom: 20px;
            }

            .error-message {
                text-align: center;
                color: #e74c3c;
                font-size: 1.2rem;
            }

            .success-message {
                text-align: center;
                color: #2ecc71;
                font-size: 1.2rem;
            }

            /* Responsive Design */
            @media (max-width: 768px) {
                .container {
                    padding: 15px;
                }

                .card {
                    padding: 15px;
                }
            }

        </style>
    </head>
    <body>
        <div class="container">
            <h2>Election Results</h2>

            <%
                String election_id = request.getParameter("election_id");  // Retrieve the election_id from URL parameters
                if (election_id == null || election_id.trim().isEmpty()) {
                    out.println("<div class='error-message'>Missing election ID.</div>");
                    return;
                }

                List<CandidateResult> results = (List<CandidateResult>) request.getAttribute("results");
            %>

            <% if (results != null && !results.isEmpty()) { %>
                <div class="results-container">
                    <p><strong>Total Votes in Election <%= election_id %>:</strong> <%= request.getAttribute("totalVotes") %></p>

                    <% for (CandidateResult cr : results) { %>
                    <div class="card">
                        <div class="candidate-name"><%= cr.getUser_name() %></div>
                        <div class="muted">Votes: <%= cr.getVote_count() %></div>
                        
                        <div class="bar">
                            <div class="bar-fill" style="width:<%= Math.max(1, cr.getPercentage()) %>%;"></div>
                        </div>

                        <div class="percentage"><%= String.format("%.1f", cr.getPercentage()) %>%</div>

                        <p><%= cr.getManifesto() %></p>
                    </div>
                    <% } %>
                </div>

            <% } else { %>
                <div class="error-message">No results available for election <%= election_id %>.</div>
            <% } %>

            <a href="javascript:history.back()" class="back-link">Back to Homepage</a>
        </div>
    </body>
</html>
