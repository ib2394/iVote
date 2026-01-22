<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%
    String election_id_str = request.getParameter("election_id");
    
    Integer user_id = (Integer) session.getAttribute("user_id");
    String user_name = (String) session.getAttribute("user_name");
    
    if (user_id == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String vote_candidate_id = request.getParameter("vote_candidate_id");
    String vote_election_id = request.getParameter("vote_election_id");
    
    if (vote_candidate_id != null && vote_election_id != null) {
        try {
            int candidate_id = Integer.parseInt(vote_candidate_id);
            int election_id = Integer.parseInt(vote_election_id);
            
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            Connection conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            
            String checkSql = "SELECT COUNT(*) as count FROM VOTE WHERE USER_ID = ? AND ELECTION_ID = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, user_id);
            checkStmt.setInt(2, election_id);
            ResultSet rs = checkStmt.executeQuery();
            
            boolean alreadyVoted = false;
            if (rs.next()) {
                alreadyVoted = rs.getInt("count") > 0;
            }
            rs.close();
            checkStmt.close();
            
            if (!alreadyVoted) {
                String insertSql = "INSERT INTO VOTE (USER_ID, CANDIDATE_ID, ELECTION_ID, VOTE_TIME) VALUES (?, ?, ?, CURRENT_DATE)";
                PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                insertStmt.setInt(1, user_id);
                insertStmt.setInt(2, candidate_id);
                insertStmt.setInt(3, election_id);
                
                insertStmt.executeUpdate();
                insertStmt.close();
                
                String updateSql = "UPDATE USERS SET STATUS = 'voted' WHERE USER_ID = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setInt(1, user_id);
                updateStmt.executeUpdate();
                updateStmt.close();
                
                session.setAttribute("message", "Thank you for voting! Your vote has been recorded successfully.");
                session.setAttribute("messageType", "success");
                
                conn.close();
                
                response.sendRedirect("homepage.jsp");
                return;
            }
            
            conn.close();
            
        } catch (Exception e) {
            out.println("<p style='color:red; padding: 20px;'>Error: " + e.getMessage() + "</p>");
        }
    }
    
    int election_id = 0;
    String election_name = "";
    boolean alreadyVoted = false;
    List<Map<String, Object>> candidates = new ArrayList<>();
    
    if (election_id_str != null && !election_id_str.isEmpty()) {
        try {
            election_id = Integer.parseInt(election_id_str);
            
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            Connection conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            
            String electionSql = "SELECT ELECTION_NAME FROM ELECTION WHERE ELECTION_ID = ?";
            PreparedStatement electionStmt = conn.prepareStatement(electionSql);
            electionStmt.setInt(1, election_id);
            ResultSet electionRs = electionStmt.executeQuery();
            
            if (electionRs.next()) {
                election_name = electionRs.getString("ELECTION_NAME");
            }
            electionRs.close();
            electionStmt.close();
            
            String voteSql = "SELECT COUNT(*) as count FROM VOTE WHERE USER_ID = ? AND ELECTION_ID = ?";
            PreparedStatement voteStmt = conn.prepareStatement(voteSql);
            voteStmt.setInt(1, user_id);
            voteStmt.setInt(2, election_id);
            ResultSet voteRs = voteStmt.executeQuery();
            
            if (voteRs.next()) {
                alreadyVoted = voteRs.getInt("count") > 0;
            }
            voteRs.close();
            voteStmt.close();
            
            String candidateSql = "SELECT CANDIDATE_ID, CANDIDATE_NAME, EMAIL, FACULTY, MANIFESTO FROM CANDIDATES WHERE ELECTION_ID = ?";
            PreparedStatement candidateStmt = conn.prepareStatement(candidateSql);
            candidateStmt.setInt(1, election_id);
            ResultSet candidateRs = candidateStmt.executeQuery();
            
            while (candidateRs.next()) {
                Map<String, Object> candidate = new HashMap<>();
                candidate.put("id", candidateRs.getInt("CANDIDATE_ID"));
                candidate.put("name", candidateRs.getString("CANDIDATE_NAME"));
                candidate.put("email", candidateRs.getString("EMAIL"));
                candidate.put("faculty", candidateRs.getString("FACULTY"));
                candidate.put("manifesto", candidateRs.getString("MANIFESTO"));
                candidates.add(candidate);
            }
            
            candidateRs.close();
            candidateStmt.close();
            conn.close();
            
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Vote for <%= election_name %></title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
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
            text-align: center;
        }
        
        .header h1 {
            margin: 0;
            font-size: 24px;
        }
        
        .user-info {
            background: #f8f9ff;
            padding: 15px 20px;
            border-bottom: 1px solid #e0e0ff;
            font-size: 14px;
            color: #333;
        }
        
        .content {
            padding: 20px;
        }
        
        .candidate-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 15px;
        }
        
        .candidate-name {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin: 0 0 5px;
        }
        
        .candidate-email {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        
        .candidate-faculty {
            display: inline-block;
            background: #e0e0ff;
            color: #6a0dad;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 12px;
            margin-bottom: 10px;
        }
        
        .manifesto {
            background: #f9f9f9;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
            font-size: 14px;
            line-height: 1.5;
            color: #555;
        }
        
        .vote-btn {
            background: green;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            width: 100%;
            font-size: 16px;
            margin-top: 10px;
        }
        
        .vote-btn:hover:not(:disabled) {
            background: darkgreen;
        }
        
        .vote-btn:disabled {
            background: gray;
            cursor: not-allowed;
        }
        
        .already-voted {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: center;
        }
        
        .back-btn {
            display: inline-block;
            margin-top: 20px;
            color: #6a0dad;
            text-decoration: none;
            font-weight: bold;
        }
        
        .back-btn:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Vote for: <%= election_name %></h1>
        </div>
        
        <div class="user-info">
            <strong>Logged in as:</strong> <%= user_name %> | <strong>User ID:</strong> <%= user_id %>
        </div>
        
        <div class="content">
            <% if (alreadyVoted) { %>
                <div class="already-voted">
                    <h3>You have already voted in this election.</h3>
                    <p>Thank you for participating!</p>
                    <a href="homepage.jsp" class="back-btn">Back to Homepage</a>
                </div>
            <% } %>
            
            <h2 style="color: #333; margin-bottom: 20px;">Candidates (<%= candidates.size() %>):</h2>
            
            <% if (candidates.isEmpty()) { %>
                <div style="text-align: center; padding: 30px; color: #666;">
                    <p>No candidates have registered for this election.</p>
                </div>
            <% } else { %>
                <% for (Map<String, Object> candidate : candidates) { %>
                    <div class="candidate-card">
                        <h3 class="candidate-name"><%= candidate.get("name") %></h3>
                        <p class="candidate-email"><%= candidate.get("email") %></p>
                        
                        <% if (candidate.get("faculty") != null && !candidate.get("faculty").toString().isEmpty()) { %>
                            <div class="candidate-faculty">
                                <%= candidate.get("faculty") %>
                            </div>
                        <% } %>
                        
                        <div class="manifesto">
                            <strong>Manifesto:</strong><br>
                            <%= candidate.get("manifesto") != null && !candidate.get("manifesto").toString().isEmpty() 
                                ? candidate.get("manifesto") 
                                : "No manifesto provided." %>
                        </div>
                        
                        <% if (!alreadyVoted) { %>
                            <form method="post">
                                <input type="hidden" name="vote_candidate_id" value="<%= candidate.get("id") %>">
                                <input type="hidden" name="vote_election_id" value="<%= election_id %>">
                                <button type="submit" class="vote-btn">
                                    Vote for <%= candidate.get("name") %>
                                </button>
                            </form>
                        <% } else { %>
                            <button class="vote-btn" disabled>
                                Already Voted
                            </button>
                        <% } %>
                    </div>
                <% } %>
            <% } %>
            
            <br>
            <a href="homepage.jsp" class="back-btn">
                Back to Homepage
            </a>
        </div>
    </div>
</body>
</html>