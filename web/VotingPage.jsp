<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="bean.*"%>
<%@page import="dao.*"%>
<%@page import="java.util.*"%>
<%
    // Debug: Print session attributes
    System.out.println("DEBUG: Session ID = " + session.getId());
    System.out.println("DEBUG: user_id in session = " + session.getAttribute("user_id"));
    System.out.println("DEBUG: user_name in session = " + session.getAttribute("user_name"));
    System.out.println("DEBUG: role in session = " + session.getAttribute("role"));
    
    // Check for user in session
    Integer user_id = (Integer) session.getAttribute("user_id");
    String user_name = (String) session.getAttribute("user_name");
    String role = (String) session.getAttribute("role");
    
    /*if (!"student".equalsIgnoreCase(role) && !"lecturer".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }*/
    // If no user_id in session, try to get it from URL parameter
    if (user_id == null) {
        String user_idParam = request.getParameter("user_id");
        if (user_idParam != null && !user_idParam.isEmpty()) {
            try {
                user_id = Integer.parseInt(user_idParam);
                session.setAttribute("user_id", user_id);
                System.out.println("DEBUG: Got user_id from URL parameter: " + user_id);
            } catch (NumberFormatException e) {
                System.out.println("DEBUG: Invalid user_id parameter: " + user_idParam);
            }
        }
    }
    
    // If still no user_id, check for old format user object
    if (user_id == null) {
        Users currentUser = (Users) session.getAttribute("user");
        if (currentUser != null) {
            user_id = currentUser.getUser_id();
            user_name = currentUser.getUser_name();
            role = currentUser.getRole();
            session.setAttribute("user_id", user_id);
            session.setAttribute("user_name", user_name);
            session.setAttribute("role", role);
            System.out.println("DEBUG: Got user from old format object: " + user_id);
        }
    }
    
    if (user_id == null) {
        System.out.println("DEBUG: No user_id found, redirecting to login");
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Check if user is a student (note: in your system it's "user" not "student")
    if (role == null || (!"student".equalsIgnoreCase(role))) {
        System.out.println("DEBUG: User role is not user, redirecting to login");
        response.sendRedirect("login.jsp");
        return;
    }
    
    String election_idParam = request.getParameter("election_id");
    int election_id = 0;
    
    if (election_idParam != null && !election_idParam.isEmpty()) {
        try {
            election_id = Integer.parseInt(election_idParam);
            System.out.println("DEBUG: Election ID from parameter: " + election_id);
        } catch (NumberFormatException e) {
            System.out.println("DEBUG: Invalid election ID parameter: " + election_idParam);
            response.sendRedirect("homepage.jsp?error=Invalid election ID");
            return;
        }
    }
    ElectionDAO electionDAO = new ElectionDAO();
    CandidateDAO candidateDAO = new CandidateDAO();
    VoteDAO voteDAO = new VoteDAO();
    
    // Get the election
    Election election = null;
    if (election_id > 0) {
        election = electionDAO.getElectionById(election_id);
    } else {
        // Fallback to active election
        election = electionDAO.getActiveElection();
    }
    
    System.out.println("DEBUG: Election object: " + election);
    
    // Get candidates and voting status
    List<CandidateView> candidates = null;
    boolean alreadyVoted = false;
    
    if (election != null) {
        candidates = candidateDAO.getCandidateViewsByElection(election.getElection_id());
        System.out.println("DEBUG: Number of candidates: " + (candidates != null ? candidates.size() : 0));
        
        // Check if user has already voted in this election
        alreadyVoted = voteDAO.hasVotedInElection(user_id, election.getElection_id());
        System.out.println("DEBUG: Already voted: " + alreadyVoted);
    } else {
        candidates = new ArrayList<CandidateView>();
        System.out.println("DEBUG: No election found");
    }
    
    // Get message parameters
    String voteStatus = request.getParameter("vote");
    String errorStatus = request.getParameter("error");
    
    System.out.println("DEBUG: voteStatus = " + voteStatus);
    System.out.println("DEBUG: errorStatus = " + errorStatus);
    System.out.println("DEBUG: Election ID = " + (election != null ? election.getElection_id() : "null"));
    System.out.println("DEBUG: Election Name = " + (election != null ? election.getElection_name() : "null"));
    
    if (election != null) {
        candidates = candidateDAO.getCandidateViewsByElection(election.getElection_id());
        System.out.println("DEBUG: Candidates object = " + candidates);
        System.out.println("DEBUG: Candidates list size = " + (candidates != null ? candidates.size() : "null"));
        
        if (candidates != null && !candidates.isEmpty()) {
            System.out.println("DEBUG: First candidate details:");
            CandidateView first = candidates.get(0);
            System.out.println("  Candidate ID: " + first.getCandidate_id());
            System.out.println("  Candidate Name: " + first.getUser_name());
            System.out.println("  Email: " + first.getEmail());
            System.out.println("  Faculty: " + first.getFaculty());
            System.out.println("  Manifesto: " + first.getManifesto());
        } else {
            System.out.println("DEBUG: Candidates list is empty or null");
        }
        
        // Check database directly (temporary debug)
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            Connection debugConn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
            String debugSql = "SELECT COUNT(*) as count FROM CANDIDATES WHERE election_id = ?";
            PreparedStatement debugStmt = debugConn.prepareStatement(debugSql);
            debugStmt.setInt(1, election.getElection_id());
            ResultSet debugRs = debugStmt.executeQuery();
            if (debugRs.next()) {
                System.out.println("DEBUG: Direct DB query - Candidates count for election " + election.getElection_id() + " = " + debugRs.getInt("count"));
            }
            debugRs.close();
            debugStmt.close();
            debugConn.close();
        } catch (Exception e) {
            System.out.println("DEBUG: Direct DB query error: " + e.getMessage());
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Voting Page</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            * { 
                margin: 0; 
                padding: 0; 
                box-sizing: border-box; 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            }
            
            body {
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                min-height: 100vh;
            }
            
            /* Navbar */
            .navbar {
                background: linear-gradient(to right, #6a0dad, #3498db);
                color: white;
                padding: 1rem 2rem;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            }
            
            .navbar-brand {
                font-size: 1.8rem;
                font-weight: bold;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            
            .navbar-user {
                display: flex;
                align-items: center;
                gap: 20px;
            }
            
            .user-name {
                font-weight: 500;
                font-size: 1.1rem;
            }
            
            .logout-btn {
                background-color: rgba(255, 255, 255, 0.2);
                color: white;
                border: 1px solid rgba(255, 255, 255, 0.3);
                padding: 8px 20px;
                border-radius: 25px;
                cursor: pointer;
                font-weight: 500;
                transition: all 0.3s ease;
                text-decoration: none;
                display: inline-block;
            }
            
            .logout-btn:hover {
                background-color: rgba(255, 255, 255, 0.3);
                transform: translateY(-2px);
            }
            
            .container {
                max-width: 1200px;
                margin: 2rem auto;
                padding: 0 1.5rem;
            }
            
            .page-title {
                text-align: center;
                color: #6a0dad;
                margin-bottom: 2.5rem;
                font-size: 2.2rem;
                position: relative;
                padding-bottom: 15px;
            }
            
            .page-title::after {
                content: '';
                position: absolute;
                bottom: 0;
                left: 50%;
                transform: translateX(-50%);
                width: 100px;
                height: 4px;
                background: linear-gradient(to right, #6a0dad, #3498db);
                border-radius: 2px;
            }
            
            /* Election Info Card */
            .election-info-card {
                background: white;
                border-radius: 15px;
                padding: 2rem;
                margin-bottom: 2rem;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                border-left: 5px solid #6a0dad;
            }
            
            .election-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 1.5rem;
            }
            
            .election-title {
                font-size: 1.5rem;
                color: #333;
                margin: 0;
            }
            
            .election-status {
                display: inline-block;
                padding: 6px 15px;
                border-radius: 20px;
                font-size: 0.9rem;
                font-weight: 600;
                text-transform: uppercase;
            }
            
            .status-open {
                background-color: #d4edda;
                color: #155724;
            }
            
            .status-closed {
                background-color: #f8d7da;
                color: #721c24;
            }
            
            .status-upcoming {
                background-color: #fff3cd;
                color: #856404;
            }
            
            .election-details {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 1.5rem;
                margin-top: 1.5rem;
            }
            
            .detail-item {
                background: #f8f9ff;
                padding: 1.2rem;
                border-radius: 10px;
                border: 1px solid #e0e0ff;
            }
            
            .detail-label {
                display: block;
                font-size: 0.9rem;
                color: #666;
                margin-bottom: 0.5rem;
                font-weight: 500;
            }
            
            .detail-value {
                font-size: 1.1rem;
                color: #333;
                font-weight: 600;
            }
            
            /* Voting Status */
            .voting-status {
                background: white;
                border-radius: 15px;
                padding: 1.5rem;
                margin-bottom: 2rem;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                text-align: center;
            }
            
            .voted-message {
                background-color: #d4edda;
                color: #155724;
                padding: 1rem;
                border-radius: 8px;
                margin: 1rem 0;
            }
            
            .not-voted-message {
                background-color: #fff3cd;
                color: #856404;
                padding: 1rem;
                border-radius: 8px;
                margin: 1rem 0;
            }
            
            /* Candidates Section */
            .candidates-section {
                background: white;
                border-radius: 15px;
                padding: 2rem;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                border-left: 5px solid #3498db;
            }
            
            .section-title {
                font-size: 1.5rem;
                color: #333;
                margin-bottom: 1.5rem;
            }
            
            .candidates-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                gap: 1.5rem;
            }
            
            .candidate-card {
                background: linear-gradient(135deg, #f8f9ff 0%, #f0f2ff 100%);
                border-radius: 12px;
                padding: 1.5rem;
                border: 2px solid #e0e0e0;
                transition: all 0.3s ease;
            }
            
            .candidate-card:hover {
                transform: translateY(-5px);
                border-color: #9b59b6;
                box-shadow: 0 8px 16px rgba(106, 13, 173, 0.1);
            }
            
            .candidate-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                margin-bottom: 1rem;
            }
            
            .candidate-name {
                font-size: 1.3rem;
                color: #333;
                margin: 0;
                font-weight: 600;
            }
            
            .candidate-email {
                color: #666;
                font-size: 0.9rem;
                margin: 0.3rem 0;
            }
            
            .candidate-faculty {
                display: inline-block;
                background: #e0e0ff;
                color: #6a0dad;
                padding: 4px 12px;
                border-radius: 15px;
                font-size: 0.8rem;
                font-weight: 500;
                margin-bottom: 1rem;
            }
            
            .candidate-manifesto {
                background: white;
                padding: 1rem;
                border-radius: 8px;
                border: 1px solid #e0e0e0;
                margin: 1rem 0;
                font-size: 0.95rem;
                line-height: 1.5;
                color: #555;
                min-height: 100px;
            }
            
            /* Vote Button */
            .vote-btn {
                background: linear-gradient(to right, #28a745, #20c997);
                color: white;
                border: none;
                padding: 12px 24px;
                border-radius: 25px;
                cursor: pointer;
                font-weight: 600;
                font-size: 1rem;
                width: 100%;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
            }
            
            .vote-btn:hover:not(:disabled) {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(40, 167, 69, 0.2);
            }
            
            .vote-btn:disabled {
                background: #cccccc;
                cursor: not-allowed;
                transform: none;
                box-shadow: none;
            }
            
            /* Messages */
            .message {
                padding: 1rem;
                border-radius: 8px;
                margin-bottom: 1.5rem;
                text-align: center;
            }
            
            .success-message {
                background: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }
            
            .error-message {
                background: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }
            
            /* Empty State */
            .empty-state {
                text-align: center;
                padding: 3rem;
                color: #666;
            }
            
            .empty-icon {
                font-size: 4rem;
                color: #ddd;
                margin-bottom: 1rem;
            }
            
            .back-btn {
                background: linear-gradient(to right, #6a0dad, #3498db);
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 25px;
                cursor: pointer;
                font-weight: 500;
                text-decoration: none;
                display: inline-block;
                margin-top: 1rem;
            }
            
            @media (max-width: 768px) {
                .candidates-grid {
                    grid-template-columns: 1fr;
                }
                
                .election-header {
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 1rem;
                }
            }
        </style>
    </head>
    <body>
        <!-- Navbar -->
        <nav class="navbar">
            <div class="navbar-brand">
                <i class="fas fa-vote-yea"></i>
                <span>iVote System</span>
            </div>
            <div class="navbar-user">
                <span class="user-name">
                    <%= user_name != null ? user_name : "User" %>
                </span>
                <button class="logout-btn" onclick="logout()">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </div>
        </nav>

        <!-- Main Container -->
        <div class="container">
            <h1 class="page-title">Voting Center</h1>
            
            <!-- Display Messages -->
            <% if ("success".equals(voteStatus)) { %>
                <div class="message success-message">
                    <i class="fas fa-check-circle"></i> Your vote has been recorded successfully!
                </div>
            <% } else if ("failed".equals(voteStatus)) { %>
                <div class="message error-message">
                    <i class="fas fa-times-circle"></i> Failed to record your vote. Please try again.
                </div>
            <% } else if (errorStatus != null) { %>
                <div class="message error-message">
                    <i class="fas fa-exclamation-triangle"></i> <%= errorStatus %>
                </div>
            <% } %>
            
            <% if (election == null) { %>
                <!-- No Election Found -->
                <div class="empty-state">
                    <i class="fas fa-calendar-times empty-icon"></i>
                    <h2>No Election Found</h2>
                    <p>There is no active election at the moment.</p>
                    <a href="homepage.jsp" class="back-btn">
                        <i class="fas fa-arrow-left"></i> Back to Homepage
                    </a>
                </div>
            <% } else { %>
                <!-- Election Information -->
                <div class="election-info-card">
                    <div class="election-header">
                        <h2 class="election-title"><%= election.getElection_name() %></h2>
                        <span class="election-status status-<%= election.getStatus().toLowerCase() %>">
                            <%= election.getStatus() %>
                        </span>
                    </div>
                    
                    <div class="election-details">
                        <div class="detail-item">
                            <span class="detail-label">Election ID</span>
                            <span class="detail-value">#<%= election.getElection_id() %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Start Date</span>
                            <span class="detail-value"><%= election.getStart_date() != null ? election.getStart_date().toString() : "N/A" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">End Date</span>
                            <span class="detail-value"><%= election.getEnd_date() != null ? election.getEnd_date().toString() : "N/A" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Candidates</span>
                            <span class="detail-value"><%= candidates != null ? candidates.size() : 0 %></span>
                        </div>
                    </div>
                </div>
                
                <!-- Voting Status -->
                <div class="voting-status">
                    <% if (alreadyVoted) { %>
                        <div class="voted-message">
                            <i class="fas fa-check-circle"></i> You have already voted in this election.
                        </div>
                        <p>Your vote has been recorded. Thank you for participating!</p>
                    <% } else { %>
                        <div class="not-voted-message">
                            <i class="fas fa-exclamation-circle"></i> You have not voted yet in this election.
                        </div>
                        <p>Please select your preferred candidate below and click "Vote".</p>
                    <% } %>
                </div>
                
                <!-- Candidates Section -->
                <div class="candidates-section">
                    <h2 class="section-title">Candidates</h2>
                    
                    <% if (candidates == null || candidates.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-user-times empty-icon"></i>
                            <h3>No Candidates</h3>
                            <p>No candidates have registered for this election.</p>
                        </div>
                    <% } else { %>
                        <div class="candidates-grid">
                            <% for (CandidateView candidate : candidates) { %>
                                <div class="candidate-card">
                                    <div class="candidate-header">
                                        <div>
                                            <h3 class="candidate-name"><%= candidate.getUser_name() %></h3>
                                            <p class="candidate-email"><%= candidate.getEmail() %></p>
                                        </div>
                                    </div>
                                    
                                    <% if (candidate.getFaculty() != null && !candidate.getFaculty().isEmpty()) { %>
                                        <div class="candidate-faculty">
                                            <i class="fas fa-university"></i> <%= candidate.getFaculty() %>
                                        </div>
                                    <% } %>
                                    
                                    <div class="candidate-manifesto">
                                        <strong>Manifesto:</strong><br>
                                        <%= candidate.getManifesto() != null && !candidate.getManifesto().isEmpty() 
                                            ? candidate.getManifesto() 
                                            : "No manifesto provided." %>
                                    </div>
                                    
                                    <form method="post" action="VotingServlet">
                                        <input type="hidden" name="candidate_id" value="<%= candidate.getCandidate_id() %>">
                                        <input type="hidden" name="election_id" value="<%= election.getElection_id() %>">
                                        <input type="hidden" name="user_id" value="<%= user_id %>">
                                        
                                        <button type="submit" class="vote-btn" <%= alreadyVoted ? "disabled" : "" %>>
                                            <i class="fas fa-vote-yea"></i>
                                            <%= alreadyVoted ? "Already Voted" : "Vote for this Candidate" %>
                                        </button>
                                    </form>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

        <script>
            function logout() {
                if (confirm('Are you sure you want to logout?')) {
                    window.location.href = 'LogoutServlet';
                }
            }
            
            // Auto-hide success messages after 5 seconds
            setTimeout(function () {
                const successMessages = document.querySelectorAll('.success-message');
                successMessages.forEach(msg => {
                    msg.style.transition = 'opacity 0.5s';
                    msg.style.opacity = '0';
                    setTimeout(() => msg.remove(), 500);
                });
            }, 5000);
        </script>
    </body>
</html>