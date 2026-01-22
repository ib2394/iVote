<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%
    System.out.println("=== DEBUG resultPage.jsp ===");
    Enumeration<String> sessionNames = session.getAttributeNames();
    while (sessionNames.hasMoreElements()) {
        String name = sessionNames.nextElement();
        Object value = session.getAttribute(name);
        System.out.println("Session: " + name + " = " + value);
    }
    
    String election_id_str = request.getParameter("election_id");
    System.out.println("Election ID from parameter: " + election_id_str);
    
    Integer user_id = (Integer) session.getAttribute("user_id");
    String user_role = (String) session.getAttribute("user_role");
    String user_name = (String) session.getAttribute("user_name");
    
    System.out.println("User ID from session: " + user_id);
    System.out.println("User Role from session: " + user_role);
    System.out.println("User Name from session: " + user_name);
    
    if (user_id == null) {
        System.out.println("DEBUG: User ID is null, redirecting to login.jsp");
        response.sendRedirect("login.jsp");
        return;
    }
    
    int election_id = 0;
    String election_name = "";
    String start_date = "";
    String end_date = "";
    int total_votes = 0;
    int total_voters = 0;
    List<Map<String, Object>> candidates = new ArrayList<>();
    
    if (election_id_str != null && !election_id_str.isEmpty()) {
        try {
            election_id = Integer.parseInt(election_id_str);
            
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            Connection conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            
            String electionSql = "SELECT ELECTION_NAME, START_DATE, END_DATE FROM ELECTION WHERE ELECTION_ID = ?";
            PreparedStatement electionStmt = conn.prepareStatement(electionSql);
            electionStmt.setInt(1, election_id);
            ResultSet electionRs = electionStmt.executeQuery();
            
            if (electionRs.next()) {
                election_name = electionRs.getString("ELECTION_NAME");
                start_date = electionRs.getString("START_DATE");
                end_date = electionRs.getString("END_DATE");
            }
            electionRs.close();
            electionStmt.close();
            
            String voteCountSql = "SELECT COUNT(*) as vote_count FROM VOTE WHERE ELECTION_ID = ?";
            PreparedStatement voteCountStmt = conn.prepareStatement(voteCountSql);
            voteCountStmt.setInt(1, election_id);
            ResultSet voteCountRs = voteCountStmt.executeQuery();
            
            if (voteCountRs.next()) {
                total_votes = voteCountRs.getInt("vote_count");
            }
            voteCountRs.close();
            voteCountStmt.close();
            
            String voterCountSql = "SELECT COUNT(*) as voter_count FROM USERS WHERE ROLE = 'student'";
            Statement voterCountStmt = conn.createStatement();
            ResultSet voterCountRs = voterCountStmt.executeQuery(voterCountSql);
            
            if (voterCountRs.next()) {
                total_voters = voterCountRs.getInt("voter_count");
            }
            voterCountRs.close();
            voterCountStmt.close();
            
            String candidateSql = "SELECT c.CANDIDATE_ID, c.CANDIDATE_NAME, c.EMAIL, c.FACULTY, c.MANIFESTO, " +
                                  "COUNT(v.VOTE_ID) as vote_count " +
                                  "FROM CANDIDATES c " +
                                  "LEFT JOIN VOTE v ON c.CANDIDATE_ID = v.CANDIDATE_ID AND v.ELECTION_ID = ? " +
                                  "WHERE c.ELECTION_ID = ? " +
                                  "GROUP BY c.CANDIDATE_ID, c.CANDIDATE_NAME, c.EMAIL, c.FACULTY, c.MANIFESTO " +
                                  "ORDER BY vote_count DESC";
            PreparedStatement candidateStmt = conn.prepareStatement(candidateSql);
            candidateStmt.setInt(1, election_id);
            candidateStmt.setInt(2, election_id);
            ResultSet candidateRs = candidateStmt.executeQuery();
            
            while (candidateRs.next()) {
                Map<String, Object> candidate = new HashMap<>();
                candidate.put("id", candidateRs.getInt("CANDIDATE_ID"));
                candidate.put("name", candidateRs.getString("CANDIDATE_NAME"));
                candidate.put("email", candidateRs.getString("EMAIL"));
                candidate.put("faculty", candidateRs.getString("FACULTY"));
                candidate.put("manifesto", candidateRs.getString("MANIFESTO"));
                candidate.put("vote_count", candidateRs.getInt("vote_count"));
                candidates.add(candidate);
            }
            
            candidateRs.close();
            candidateStmt.close();
            conn.close();
            
        } catch (Exception e) {
            out.println("<p style='color:red; padding: 20px;'>Database Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }
    
    for (Map<String, Object> candidate : candidates) {
        int votes = (int) candidate.get("vote_count");
        double percentage = (total_votes > 0) ? (votes * 100.0 / total_votes) : 0;
        candidate.put("percentage", String.format("%.1f", percentage));
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Election Results | iVote</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: #6a0dad;
            color: white;
            padding: 20px;
        }
        
        .header h1 {
            margin: 0 0 10px 0;
            font-size: 24px;
        }
        
        .header .back-link {
            color: white;
            text-decoration: none;
            font-size: 14px;
        }
        
        .header .back-link:hover {
            text-decoration: underline;
        }
        
        .election-info {
            background: #f8f9ff;
            padding: 15px 20px;
            border-bottom: 1px solid #e0e0ff;
            color: #333;
        }
        
        .election-info h2 {
            margin: 0 0 10px 0;
            color: #6a0dad;
        }
        
        .election-info .details {
            display: flex;
            gap: 20px;
            font-size: 14px;
        }
        
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 20px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .stat-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
        }
        
        .stat-card h3 {
            margin: 0 0 10px 0;
            color: #666;
            font-size: 14px;
        }
        
        .stat-card .value {
            font-size: 32px;
            font-weight: bold;
            color: #6a0dad;
            margin: 0;
        }
        
        .stat-card .subtext {
            font-size: 12px;
            color: #888;
            margin: 5px 0 0 0;
        }
        
        .results-content {
            padding: 20px;
        }
        
        .results-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .results-header h2 {
            margin: 0;
            color: #333;
        }
        
        .candidate-results {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .candidate-result-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            position: relative;
            transition: transform 0.2s;
        }
        
        .candidate-result-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .candidate-result-card.winner {
            border: 2px solid #4CAF50;
            background: #f8fff8;
        }
        
        .winner-badge {
            position: absolute;
            top: -10px;
            right: 20px;
            background: #4CAF50;
            color: white;
            padding: 3px 10px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .candidate-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 10px;
        }
        
        .candidate-name {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin: 0;
        }
        
        .candidate-votes {
            font-size: 24px;
            font-weight: bold;
            color: #6a0dad;
            margin: 0;
        }
        
        .candidate-details {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        
        .progress-bar {
            height: 20px;
            background: #f0f0f0;
            border-radius: 10px;
            margin: 10px 0;
            overflow: hidden;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #6a0dad, #8a2be2);
            border-radius: 10px;
            transition: width 0.5s ease-in-out;
            min-width: 20px;
        }
        
        .vote-info {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #666;
        }
        
        .manifesto {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
            font-size: 14px;
            line-height: 1.5;
            color: #555;
            border-left: 3px solid #6a0dad;
        }
        
        .no-candidates {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .summary {
            background: #f8f9ff;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            border-left: 3px solid #6a0dad;
        }
        
        .summary h3 {
            margin: 0 0 10px 0;
            color: #6a0dad;
        }
        
        .summary p {
            margin: 5px 0;
            color: #555;
        }
        
        @media (max-width: 768px) {
            .stats-container {
                grid-template-columns: 1fr;
            }
            
            .candidate-header {
                flex-direction: column;
                gap: 10px;
            }
            
            .election-info .details {
                flex-direction: column;
                gap: 5px;
            }
        }
        
        /* Debug info styling */
        .debug-info {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 10px;
            margin: 10px;
            border-radius: 5px;
            font-size: 12px;
            color: #856404;
        }
    </style>
</head>
<body>
    <div class="container">
        
        <div class="header">
            <h1>Election Results</h1>
            <a href="adminDashboard.jsp" class="back-link">Back to Admin Dashboard</a>
        </div>
        
        <div class="election-info">
            <h2><%= election_name %></h2>
            <div class="details">
                <div><strong>Start Date:</strong> <%= start_date %></div>
                <div><strong>End Date:</strong> <%= end_date %></div>
            </div>
        </div>
        
        <div class="stats-container">
            <div class="stat-card">
                <h3>Total Votes</h3>
                <p class="value"><%= total_votes %></p>
                <p class="subtext">votes cast in this election</p>
            </div>
            
            <div class="stat-card">
                <h3>Voter Turnout</h3>
                <p class="value">
                    <% if (total_voters > 0) { 
                        double turnout = (total_votes * 100.0) / total_voters;
                    %>
                        <%= String.format("%.1f", turnout) %>%
                    <% } else { %>
                        0%
                    <% } %>
                </p>
                <p class="subtext"><%= total_voters %> eligible voters</p>
            </div>
            
            <div class="stat-card">
                <h3>Candidates</h3>
                <p class="value"><%= candidates.size() %></p>
                <p class="subtext">in this election</p>
            </div>
            
            <div class="stat-card">
                <h3>Leading Candidate</h3>
                <p class="value">
                    <% if (!candidates.isEmpty()) { 
                        Map<String, Object> leadingCandidate = candidates.get(0);
                    %>
                        <%= leadingCandidate.get("name") %>
                    <% } else { %>
                        --
                    <% } %>
                </p>
                <p class="subtext">
                    <% if (!candidates.isEmpty()) { 
                        Map<String, Object> leadingCandidate = candidates.get(0);
                    %>
                        <%= leadingCandidate.get("vote_count") %> votes
                    <% } %>
                </p>
            </div>
        </div>
        
        <div class="results-content">
            <div class="results-header">
                <h2>Vote Results by Candidate</h2>
                <div style="color: #666; font-size: 14px;">
                    Sorted by most votes
                </div>
            </div>
            
            <% if (candidates.isEmpty()) { %>
                <div class="no-candidates">
                    <h3>No candidates participated in this election</h3>
                    <p>There are no results to display.</p>
                </div>
            <% } else { %>
                <div class="candidate-results">
                    <% 
                    int maxVotes = 0;
                    if (!candidates.isEmpty()) {
                        maxVotes = (int) candidates.get(0).get("vote_count");
                    }
                    
                    for (int i = 0; i < candidates.size(); i++) {
                        Map<String, Object> candidate = candidates.get(i);
                        boolean isWinner = (i == 0) && (maxVotes > 0);
                        String percentage = (String) candidate.get("percentage");
                    %>
                    <div class="candidate-result-card <%= isWinner ? "winner" : "" %>">
                        <% if (isWinner) { %>
                            <div class="winner-badge">WINNER</div>
                        <% } %>
                        
                        <div class="candidate-header">
                            <h3 class="candidate-name">
                                <%= (i + 1) %>. <%= candidate.get("name") %>
                            </h3>
                            <p class="candidate-votes"><%= candidate.get("vote_count") %> votes</p>
                        </div>
                        
                        <div class="candidate-details">
                            <div><%= candidate.get("email") %></div>
                            <% if (candidate.get("faculty") != null && !candidate.get("faculty").toString().isEmpty()) { %>
                                <div>Faculty: <%= candidate.get("faculty") %></div>
                            <% } %>
                        </div>
                        
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: <%= percentage %>%;"></div>
                        </div>
                        
                        <div class="vote-info">
                            <span><%= percentage %>% of total votes</span>
                            <span><%= candidate.get("vote_count") %> votes</span>
                        </div>
                        
                        <% if (candidate.get("manifesto") != null && !candidate.get("manifesto").toString().isEmpty()) { %>
                            <div class="manifesto">
                                <strong>Manifesto:</strong><br>
                                <%= candidate.get("manifesto") %>
                            </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const progressBars = document.querySelectorAll('.progress-fill');
            progressBars.forEach(bar => {
                const width = bar.style.width;
                bar.style.width = '0';
                setTimeout(() => {
                    bar.style.width = width;
                }, 100);
            });
        });
    </script>
</body>
</html>