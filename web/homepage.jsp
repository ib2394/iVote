<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.sql.*, java.util.*, java.sql.Date" %>
<%@page import="bean.Users"%>
<%@page import="bean.Election"%>
<%@page import="bean.CandidateView"%>
<%@page import="dao.ElectionDAO"%>
<%@page import="dao.CandidateDAO"%>
<%@page import="dao.VoteDAO"%>
<%@page import="dao.UserDAO"%>
<%@page import="java.util.*"%>
<%
    // Check for user in session (using either new or legacy format)
    Integer user_id = (Integer) session.getAttribute("user_id");
    String user_name = (String) session.getAttribute("user_name");
    String role = (String) session.getAttribute("role");
    String faculty = (String) session.getAttribute("faculty");
    String email = (String) session.getAttribute("email");

    // If no user_id in session, check for old format
    if (user_id == null) {
        Users currentUser = (Users) session.getAttribute("user");
        if (currentUser != null) {
            user_id = currentUser.getUser_id();
            user_name = currentUser.getUser_name();
            role = currentUser.getRole();
        }
    }

    // If still no user_id, redirect to login
    if (user_id == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Check if user is a student
    if (!"student".equalsIgnoreCase(role) && !"lecturer".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get election_id from parameter
    String electionIdParam = request.getParameter("election_id");
    int electionId = 0;

    if (electionIdParam != null && !electionIdParam.isEmpty()) {
        try {
            electionId = Integer.parseInt(electionIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("index.jsp?error=Invalid election ID");
            return;
        }
    }

    // Initialize DAOs
    ElectionDAO electionDAO = new ElectionDAO();
    CandidateDAO candidateDAO = new CandidateDAO();
    VoteDAO voteDAO = new VoteDAO();

    // Get the election
    Election election = null;
    if (electionId > 0) {
        election = electionDAO.getElectionById(electionId);
    } else {
        // Fallback to active election
        election = electionDAO.getActiveElection();
    }

    // Get candidates and voting status
    List<CandidateView> candidates = null;
    boolean alreadyVoted = false;

    if (election != null) {
        candidates = candidateDAO.getCandidateViewsByElection(election.getElection_id());

        // Check if user has already voted in this election
        alreadyVoted = voteDAO.hasVotedInElection(user_id, election.getElection_id());
    } else {
        candidates = new ArrayList<CandidateView>();
    }

    // Get message parameters
    String voteStatus = request.getParameter("vote");
    String errorStatus = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>iVote: Interactive Student Election System</title>

        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: #f5f5f5;
                margin: 0;
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
                position: sticky;
                top: 0;
                z-index: 1000;
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
                margin: 0 auto;
                padding: 2rem;
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

            /* Profile Section */
            .profile-section {
                background: white;
                border-radius: 15px;
                padding: 2rem;
                margin-bottom: 3rem;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                position: relative;
                border-left: 5px solid #6a0dad;
            }

            .section-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 1.5rem;
            }

            .section-title {
                font-size: 1.5rem;
                color: #333;
                margin: 0;
            }

            .edit-btn {
                background: linear-gradient(to right, #6a0dad, #3498db);
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 25px;
                cursor: pointer;
                font-weight: 500;
                font-size: 0.9rem;
                transition: all 0.3s ease;
                text-decoration: none;
                display: inline-block;
            }

            .edit-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(106, 13, 173, 0.3);
            }

            .profile-info {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 1.5rem;
            }

            .info-item {
                background: #f8f9ff;
                padding: 1.2rem;
                border-radius: 10px;
                border: 1px solid #e0e0ff;
            }

            .info-label {
                display: block;
                font-size: 0.9rem;
                color: #666;
                margin-bottom: 0.5rem;
                font-weight: 500;
            }

            .info-value {
                font-size: 1.1rem;
                color: #333;
                font-weight: 600;
            }

            /* Elections Section */
            .elections-section {
                background: white;
                border-radius: 15px;
                padding: 2rem;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                border-left: 5px solid #3498db;
                margin-bottom: 2rem;
            }

            .elections-title {
                font-size: 1.5rem;
                color: #333;
                margin-bottom: 1.5rem;
            }

            .elections-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
                gap: 1.5rem;
            }

            .election-card {
                background: linear-gradient(135deg, #f8f9ff 0%, #f0f2ff 100%);
                border-radius: 12px;
                padding: 1.5rem;
                border: 2px solid #e0e0e0;
                transition: all 0.3s ease;
                cursor: pointer;
            }

            .election-card:hover {
                transform: translateY(-5px);
                border-color: #9b59b6;
                box-shadow: 0 8px 16px rgba(106, 13, 173, 0.1);
            }

            .election-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                margin-bottom: 1rem;
            }

            .election-name {
                font-size: 1.2rem;
                color: #333;
                margin: 0;
                flex: 1;
            }

            .election-status {
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
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
                margin: 1rem 0;
            }

            .election-detail {
                display: flex;
                justify-content: space-between;
                margin-bottom: 0.5rem;
                padding-bottom: 0.5rem;
                border-bottom: 1px dashed #e0e0e0;
            }

            .detail-label {
                font-weight: 500;
                color: #666;
            }

            .detail-value {
                color: #333;
            }

            /* Vote Button */
            .vote-btn {
                background: linear-gradient(to right, #3498db, #5dade2);
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 25px;
                cursor: pointer;
                font-weight: 500;
                margin-top: 1rem;
                width: 100%;
                transition: all 0.3s ease;
                text-decoration: none;
                display: block;
                text-align: center;
            }

            .vote-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(52, 152, 219, 0.2);
            }

            .vote-btn:disabled {
                background: #cccccc;
                cursor: not-allowed;
                transform: none;
                box-shadow: none;
            }

            /* Message styles */
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

            /* Role-specific styles */
            .role-badge {
                display: inline-block;
                padding: 3px 10px;
                border-radius: 15px;
                font-size: 0.8rem;
                font-weight: 600;
                margin-left: 10px;
            }

            .role-admin {
                background: linear-gradient(to right, #ff416c, #ff4b2b);
                color: white;
            }

            .role-student {
                background: linear-gradient(to right, #36d1dc, #5b86e5);
                color: white;
            }

            .role-lecturer {
                background: linear-gradient(to right, #f46b45, #eea849);
                color: white;
            }
        </style>
    </head>
    <body>

        <nav class="navbar">
            <div class="navbar-brand">
                <span>🗳 iVote System</span>
            </div>
            <div class="navbar-user">
                <span class="user-name">
                    <%= user_name%> 
                    <span class="role-badge <%= "role-" + role.toLowerCase()%>">
                        <%= role.toUpperCase()%>
                    </span>
                </span>
                <button class="logout-btn" onclick="logout()">Logout</button>
            </div>
        </nav>

        <div class="container">
            <h1 class="page-title">Welcome to iVote</h1>
            
            <%
                String message = (String) session.getAttribute("message");
                String messageType = (String) session.getAttribute("messageType");

                if (message != null) {
            %>
            <div class="message <%= messageType%>-message">
                <%= message%>
            </div>
            <%
                    // Clear message after displaying
                    session.removeAttribute("message");
                    session.removeAttribute("messageType");
                }
            %>

            <section class="profile-section">
                <div class="section-header">
                    <h2 class="section-title">My Profile</h2>
                    <a href="editProfile.jsp">
                        <button class="edit-btn">Edit Profile</button>
                    </a>
                </div>

                <div class="profile-info">
                    <div class="info-item">
                        <span class="info-label">User ID</span>
                        <div class="info-value"><%= user_id != null ? user_id : "N/A"%></div>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Username</span>
                        <div class="info-value"><%= user_name%></div>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Role</span>
                        <div class="info-value"><%= role.toUpperCase()%></div>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Faculty</span>
                        <div class="info-value"><%= faculty != null ? faculty : "Not set"%></div>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Email</span>
                        <div class="info-value"><%= email != null ? email : "Not set"%></div>
                    </div>
                </div>
            </section>
                    
            <section class="elections-section">
                <h2 class="elections-title">Current Elections</h2>

                <div class="elections-grid">
                    <%
                        // Fetch all elections
                        List<Map<String, Object>> elections = new ArrayList<>();
                        try (Connection conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
                                PreparedStatement ps = conn.prepareStatement("SELECT ELECTION_ID, ELECTION_NAME, START_DATE, END_DATE, STATUS FROM ELECTION ORDER BY START_DATE DESC");
                                ResultSet rs = ps.executeQuery()) {

                            while (rs.next()) {
                                Map<String, Object> e = new HashMap<>();
                                e.put("id", rs.getInt("ELECTION_ID"));
                                e.put("election_name", rs.getString("ELECTION_NAME"));
                                e.put("start_date", rs.getDate("START_DATE"));
                                e.put("end_date", rs.getDate("END_DATE"));
                                e.put("status", rs.getString("STATUS"));

                                // Kira candidates untuk kira percentage
                                try (PreparedStatement ps2 = conn.prepareStatement("SELECT COUNT(*) FROM CANDIDATES WHERE ELECTION_ID = ?")) {
                                    ps2.setInt(1, rs.getInt("ELECTION_ID"));
                                    try (ResultSet rs2 = ps2.executeQuery()) {
                                        if (rs2.next()) {
                                            e.put("candidate_count", rs2.getInt(1));
                                        }
                                    }
                                }

                                elections.add(e);
                            }
                        } catch (SQLException e) {
                            out.println("<div class='error-message'>Error loading elections: " + e.getMessage() + "</div>");
                        }

                        // Display elections
                        if (elections.isEmpty()) {
                    %>
                    <div class="message">
                        <p>No elections available at the moment.</p>
                    </div>
                    <%
                    } else {
                        for (Map<String, Object> electionData : elections) {  // Changed from 'election' to 'electionData'
                            int election_id = (Integer) electionData.get("id");
                            String electionName = (String) electionData.get("election_name");
                            Date startDate = (Date) electionData.get("start_date");
                            Date endDate = (Date) electionData.get("end_date");
                            String status = (String) electionData.get("status");
                            int candidateCount = (Integer) electionData.get("candidate_count");

                            String statusClass = "";
                            String buttonText = "";
                            boolean isClickable = false;
                            String link = "#";

                            if ("ACTIVE".equalsIgnoreCase(status)) {
                                statusClass = "status-open";
                                buttonText = "Vote Now";
                                isClickable = true;
                                link = "VotingPage.jsp?election_id=" + election_id + "&user_id=" + user_id;
                            } else if ("UPCOMING".equalsIgnoreCase(status)) {
                                statusClass = "status-upcoming";
                                buttonText = "Starts Soon";
                                isClickable = false;
                            } else if ("CLOSED".equalsIgnoreCase(status)) {
                                statusClass = "status-closed";
                                buttonText = "View Results";
                                isClickable = true;
                                link = "resultPage.jsp?election_id=" + election_id;
                            }
                    %>
                    <div class="election-card">
                        <div class="election-header">
                            <h3 class="election-name"><%= electionName%></h3>
                            <span class="election-status <%= statusClass%>"><%= status%></span>
                        </div>
                        <div class="election-details">
                            <div class="election-detail">
                                <span class="detail-label">Start Date:</span>
                                <span class="detail-value"><%= startDate != null ? startDate.toString() : "N/A"%></span>
                            </div>
                            <div class="election-detail">
                                <span class="detail-label">End Date:</span>
                                <span class="detail-value"><%= endDate != null ? endDate.toString() : "N/A"%></span>
                            </div>
                            <div class="election-detail">
                                <span class="detail-label">Candidates:</span>
                                <span class="detail-value"><%= candidateCount%></span>
                            </div>
                        </div>
                        <% if (isClickable) {%>
                        <a href="<%= link%>" class="vote-btn"><%= buttonText%></a>
                        <% } else {%>
                        <button class="vote-btn" disabled><%= buttonText%></button>
                        <% } %>
                    </div>
                    <%
                            }
                        }
                    %>
                </div>
            </section>

            <!-- Quick Links Section (for different roles) -->
            <%
                if ("admin".equalsIgnoreCase(role)) {
            %>
            <section class="elections-section">
                <h2 class="elections-title">Admin Quick Links</h2>
                <div class="elections-grid">
                    <a href="adminDashboard.jsp" class="election-card" style="text-decoration: none; color: inherit;">
                        <h3 class="election-name">Admin Dashboard</h3>
                        <p>Manage elections, candidates, and users</p>
                    </a>
                    <a href="viewCandidates.jsp" class="election-card" style="text-decoration: none; color: inherit;">
                        <h3 class="election-name">Manage Candidates</h3>
                        <p>Add, edit, or remove candidates</p>
                    </a>
                    <a href="addElection.jsp" class="election-card" style="text-decoration: none; color: inherit;">
                        <h3 class="election-name">Create Election</h3>
                        <p>Set up a new election</p>
                    </a>
                </div>
            </section>
            <%
                }
            %>
        </div>

        <script>
            function logout() {
                if (confirm('Are you sure you want to logout?')) {
                    window.location.href = 'LogoutServlet';
                }
            }

            // Auto-hide messages after 5 seconds
            setTimeout(function () {
                const messages = document.querySelectorAll('.message');
                messages.forEach(msg => {
                    msg.style.transition = 'opacity 0.5s';
                    msg.style.opacity = '0';
                    setTimeout(() => msg.remove(), 500);
                });
            }, 5000);
        </script>
    </body>
</html>