<%@page import="java.time.temporal.ChronoUnit"%>
<%@page import="bean.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="dao.*" %>
<%@page import="java.util.*" %>
<%@page import="java.time.*" %>
<%
    Users currentUser = (Users) session.getAttribute("user");
    String legacyRole = (String) session.getAttribute("role");
    String legacyUserName = (String) session.getAttribute("userName");

    if (currentUser == null) {
        if (legacyRole == null || !"admin".equalsIgnoreCase(legacyRole)) {
            response.sendRedirect("login.jsp");
            return;
        }
    } else {
        if (!"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
    }

    ElectionDAO electionDAO = new ElectionDAO();
    CandidateDAO candidateDAO = new CandidateDAO();
    UserDAO userDAO = new UserDAO();

    if (currentUser == null && legacyUserName != null && legacyUserName.indexOf("@") > 0) {
        Users maybe = userDAO.getUserByEmail(legacyUserName);
        if (maybe != null) {
            currentUser = maybe;
            session.setAttribute("user", currentUser);
        }
    }
    VoteDAO voteDAO = new VoteDAO();

    Election activeElection = electionDAO.getActiveElection();
    int totalCandidates = candidateDAO.getTotalCandidates();
    int totalVotes = activeElection != null
            ? voteDAO.getTotalVotesByElection(activeElection.getElection_id())
            : voteDAO.getTotalVotes();
    int totalStudents = userDAO.countByRole("USER");
    int turnout = voteDAO.getVoterTurnout(totalStudents);

    List<CandidateView> candidates = null;
    if (activeElection != null) {
        candidates = candidateDAO.getCandidateViewsByElection(activeElection.getElection_id());
    } else {
        candidates = new ArrayList<CandidateView>();
    }

    String timeRemaining = "--";
    if (activeElection != null && activeElection.getEnd_date() != null) {
        LocalDate today = LocalDate.now();
        LocalDate end = activeElection.getEnd_date().toLocalDate();
        long days = ChronoUnit.DAYS.between(today, end);
        if (days >= 0) {
            timeRemaining = days + " day(s)";
        } else {
            timeRemaining = "Ended";
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Admin Dashboard</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
            body { background: #f5f7fb; min-height: 100vh; }

            header { background: linear-gradient(135deg, #1e3c72, #2a5298); color: white; }
            .header-content { display: flex; justify-content: space-between; align-items: center; max-width: 1200px; margin: 0 auto; padding: 1rem; }

            .logout-btn { background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3); color: white; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-weight: 500; }
            .logout-btn:hover { background: rgba(255,255,255,0.3); }

            main { max-width: 1200px; margin: 0 auto; padding: 2rem 1rem; }

            .admin-header { text-align: center; margin-bottom: 2rem; }
            .admin-header h2 { color: #1e3c72; margin-bottom: 0.5rem; }

            .dashboard-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
            .dashboard-card { background: white; border-radius: 10px; padding: 1.5rem; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-top: 4px solid #1e3c72; }
            .card-icon { font-size: 2.5rem; color: #1e3c72; margin-bottom: 1rem; }
            .stats { font-size: 2.5rem; font-weight: bold; color: #2a5298; margin-bottom: 0.5rem; }
            .card-title { color: #333; margin-bottom: 0.5rem; }
            .card-subtitle { color: #666; font-size: 0.9rem; }

            .admin-actions { display: flex; gap: 1rem; margin-bottom: 2rem; flex-wrap: wrap; }
            .btn { background: #1e3c72; color: white; padding: 10px 20px; border: none; border-radius: 5px; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 500; }
            .btn-success { background: #28a745; }
            .btn-warning { background: #ffc107; color: #212529; }
            .btn-danger { background: #dc3545; }
            .btn-secondary { background: #6c757d; }

            .admin-section { background: white; border-radius: 10px; padding: 1.5rem; margin-bottom: 2rem; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
            .admin-section h3 { color: #1e3c72; margin-bottom: 1rem; border-bottom: 2px solid #f0f0f0; padding-bottom: 0.5rem; }

            .form-group { margin-bottom: 1rem; }
            .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 1rem; }
            textarea.form-control { min-height: 100px; resize: vertical; }
            label { display: block; margin-bottom: 0.5rem; color: #333; font-weight: 500; }
            small { font-size: 0.85rem; }

            .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem; }

            .candidate-table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
            .candidate-table th, .candidate-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }
            .candidate-table th { background: #f8f9fa; color: #1e3c72; font-weight: 600; }
            .candidate-table tr:nth-child(even) { background: #f9f9f9; }
            .candidate-table tr:hover { background: #f0f7ff; }

            .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
            .modal-content { background: white; margin: 15% auto; padding: 20px; border-radius: 10px; width: 90%; max-width: 500px; }
            .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
            .close-btn { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: #666; }

            .empty-state { text-align: center; padding: 2rem; color: #666; }
            .empty-state i { font-size: 3rem; color: #ddd; margin-bottom: 1rem; }

            @media (max-width: 768px) {
                .admin-actions { flex-direction: column; }
                .btn { width: 100%; justify-content: center; }
            }
        </style>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <header>
            <div class="header-content">
                <div>
                    <h1 style="margin: 0; font-size: 1.5rem;">
                        <i class="fas fa-user-shield"></i> Admin Panel
                    </h1>
                    <p style="margin: 5px 0 0 0; font-size: 0.9rem; opacity: 0.9;">
                        Logged in as: <%= currentUser != null ? currentUser.getUser_name() : (legacyUserName != null ? legacyUserName : "Administrator")%>
                    </p>
                </div>
                <button class="logout-btn" onclick="logout()">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </div>
        </header>

        <main>
            <div class="admin-header">
                <h2>Admin Dashboard</h2>
                <p>Manage candidates, view results, and monitor the voting process</p>
            </div>

            <div class="admin-actions">
                <a href="CandidateListServlet" class="btn">
                    <i class="fas fa-list"></i> Manage Candidates
                </a>
                <a href="addElections.jsp" class="btn">
                    <i class="fas fa-plus-circle"></i> Create Election
                </a>
            </div>

            <!-- display all elections -->
            <div class="admin-section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                    <h3><i class="fas fa-vote-yea"></i> All Elections</h3>
                    <a href="addElections.jsp" class="btn" style="background: #28a745; padding: 6px 12px; font-size: 0.9rem;">
                        <i class="fas fa-plus-circle"></i> Create New Election
                    </a>
                </div>

                <%
                    //In ElectionDAO to declare and do allElections method
                    List<Election> allElections = electionDAO.getAllElections();

                    if (allElections == null || allElections.isEmpty()) {
                %>
                <div class="empty-state">
                    <i class="fas fa-calendar-times"></i>
                    <h4>No Elections Found</h4>
                    <p>There are no elections in the system yet.</p>
                    <a href="addElections.jsp" class="btn" style="margin-top: 1rem;">
                        <i class="fas fa-plus-circle"></i> Create New Election
                    </a>
                </div>
                <% } else { %>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(500px, 1fr)); gap: 1.5rem;">
                    <% for (Election election : allElections) {
                            String statusColor = "";
                            String statusIcon = "";
                            if ("ACTIVE".equalsIgnoreCase(election.getStatus())) {
                                statusColor = "#28a745";
                                statusIcon = "fa-bolt";
                            } else if ("UPCOMING".equalsIgnoreCase(election.getStatus())) {
                                statusColor = "#ffc107";
                                statusIcon = "fa-clock";
                            } else if ("CLOSED".equalsIgnoreCase(election.getStatus())) {
                                statusColor = "#dc3545";
                                statusIcon = "fa-ban";
                            } else {
                                statusColor = "#6c757d";
                                statusIcon = "fa-question-circle";
                            }
                    %>

                    <div style="background: white; border-radius: 10px; padding: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-left: 4px solid <%= statusColor%>;">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                            <h4 style="margin: 0; color: #1e3c72; flex: 1;">
                                <i class="fas fa-clipboard-list"></i> <%= election.getElection_name()%>
                            </h4>
                            <span style="background: <%= statusColor%>20; color: <%= statusColor%>; padding: 4px 10px; border-radius: 15px; font-size: 0.8rem; font-weight: 600;">
                                <i class="fas <%= statusIcon%>"></i> <%= election.getStatus()%>
                            </span>
                        </div>

                        <div style="margin-bottom: 1rem;">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                                <span style="color: #666; font-size: 0.9rem;">Start Date:</span>
                                <span style="font-weight: 500;"><%= election.getStart_date()%></span>
                            </div>
                            <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                                <span style="color: #666; font-size: 0.9rem;">End Date:</span>
                                <span style="font-weight: 500;"><%= election.getEnd_date()%></span>
                            </div>
                        </div>

                        <div style="display: flex; gap: 0.5rem; margin-top: 1rem;">
                            <a href="editElections.jsp?election_id=<%= election.getElection_id()%>" 
                               class="btn" style="padding: 6px 12px; font-size: 0.85rem; background: #17a2b8; flex: 1;">
                                <i class="fas fa-edit"></i> Edit
                            </a>
                            <a href="resultPage.jsp?election_id=<%= election.getElection_id()%>" 
                               class="btn" style="padding: 6px 12px; font-size: 0.85rem; background: #FADA5E; flex: 1;">
                                <i class="fas fa-edit"></i> Result
                            </a>
                            <a href="addCandidate.jsp?election_id=<%= election.getElection_id()%>" class="btn" style="padding: 6px 12px; font-size: 0.85rem; background: #6a0dad; flex: 1;">
                                <i class="fas fa-users"></i> Add Candidates
                            </a>
                            <button onclick="confirmDeleteElection(<%= election.getElection_id()%>)" 
                                    class="btn" style="padding: 6px 12px; font-size: 0.85rem; background: #dc3545; flex: 1;">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% }%>
            </div>
        </main>

        <!-- Delete Confirmation Modal -->
        <div id="delete-modal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3><i class="fas fa-exclamation-triangle"></i> Confirm Deletion</h3>
                    <button class="close-btn">&times;</button>
                </div>
                <p>Are you sure you want to delete this candidate? This action cannot be undone.</p>
                <div style="text-align: right; margin-top: 1.5rem;">
                    <button id="confirm-delete" class="btn btn-danger">
                        <i class="fas fa-trash"></i> Delete
                    </button>
                    <button id="cancel-delete" class="btn btn-secondary">Cancel</button>
                </div>
            </div>
        </div>

        <script>
            function logout() {
                if (confirm('Are you sure you want to logout?')) {
                    window.location.href = 'LogoutServlet';
                }
            }

            let candidateToDelete = null;

            function confirmDelete(candidateId) {
                candidateToDelete = candidateId;
                document.getElementById('delete-modal').style.display = 'block';
            }

            function confirmDeleteElection(electionId) {
                if (confirm('⚠️ WARNING: Deleting this election will also delete ALL candidates in this election!\n\nAre you sure you want to delete this election?')) {
                    window.location.href = 'DeleteElectionServlet?id=' + electionId;
                }
            }

            document.querySelector('.close-btn').onclick = function () {
                document.getElementById('delete-modal').style.display = 'none';
                candidateToDelete = null;
            };

            document.getElementById('cancel-delete').onclick = function () {
                document.getElementById('delete-modal').style.display = 'none';
                candidateToDelete = null;
            };

            document.getElementById('confirm-delete').onclick = function () {
                if (candidateToDelete) {
                    window.location.href = 'DeleteCandidateServlet?id=' + candidateToDelete;
                }
            };

            // Close modal when clicking outside
            window.onclick = function (event) {
                var modal = document.getElementById('delete-modal');
                if (event.target == modal) {
                    modal.style.display = 'none';
                    candidateToDelete = null;
                }
            };
        </script>
    </body>
</html>