<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.sql.Date" %>
<%@page import="bean.*"%>
<%@page import="dao.*"%>
<%
    // Check for user in session (using either new or legacy format)
    Integer user_id = (Integer) session.getAttribute("user_id");
    String user_name = (String) session.getAttribute("user_name");
    String role = (String) session.getAttribute("role");
    String faculty = (String) session.getAttribute("faculty");
    String email = (String) session.getAttribute("email");

    if (user_id == null || !"student".equalsIgnoreCase(role) && !"lecturer".equalsIgnoreCase(role)) {
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
    UserDAO userDAO = new UserDAO();
    Map<String, String> userProfile = userDAO.getUserProfile(user_id);
    
    // Update variables
    user_name = userProfile.get("user_name") != null ? userProfile.get("user_name") : user_name;
    role = userProfile.get("role") != null ? userProfile.get("role") : role;
    faculty = userProfile.get("faculty");
    email = userProfile.get("email");
    
    // Update session
    session.setAttribute("user_name", user_name);
    session.setAttribute("role", role);
    session.setAttribute("faculty", faculty);
    session.setAttribute("email", email);
    
    System.out.println("DEBUG: Fresh user data loaded:");
    System.out.println("  Name: " + user_name);
    System.out.println("  Role: " + role);
    System.out.println("  Faculty: " + faculty);
    System.out.println("  Email: " + email);

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
        <link rel="stylesheet" href="style.css">
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