<%-- 
    Document   : adminDashboard
    Created on : 20 Jan, 2026, 8:30:42 PM
    Author     : USER
--%>

<%@page import="bean.Users"%>
<%@page import="bean.Election"%>
<%@page import="bean.Position"%>
<%@page import="bean.CandidateView"%>
<%@page import="dao.UserDAO" %>
<%@page import="dao.ElectionDAO" %>
<%@page import="dao.PositionDAO" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="dao.CandidateDAO" %>
<%@page import="dao.VoteDAO" %>
<%@page import="java.util.List" %>
<%@page import="java.util.Map" %>
<%@page import="java.util.HashMap" %>
<%@page import="java.util.ArrayList" %>
<%@page import="java.util.Collections" %>
<%@page import="java.time.LocalDate" %>
<%@page import="java.time.temporal.ChronoUnit" %>
<%
    Users currentUser = (Users) session.getAttribute("user");
    String legacyRole = (String) session.getAttribute("role"); // from friend's login.jsp (admin/student/lecturer)
    String legacyUserName = (String) session.getAttribute("userName");

    // Accept either new auth (Users in session) OR legacy auth (role string in session)
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
    PositionDAO positionDAO = new PositionDAO();
    CandidateDAO candidateDAO = new CandidateDAO();
    UserDAO userDAO = new UserDAO();
    // If we came from legacy login and the legacy "userName" is actually an email, try to hydrate Users for display/use
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
    int totalStudents = userDAO.countByRole("STUDENT");
    int turnout = voteDAO.getVoterTurnout(totalStudents);

    List<Position> positions = null;
    if (activeElection != null) {
        positions = positionDAO.getPositionsByElection(activeElection.getElection_id());
    } else {
        positions = new ArrayList<Position>();
    }
    Map<Integer, List<CandidateView>> candidatesByPosition = new HashMap<Integer, List<CandidateView>>();
    if (activeElection != null) {
        List<CandidateView> candidateViews = candidateDAO.getCandidateViewsByElection(activeElection.getElection_id());
        for (CandidateView view : candidateViews) {
            if (!candidatesByPosition.containsKey(view.getPositionId())) {
                candidatesByPosition.put(view.getPositionId(), new ArrayList<CandidateView>());
            }
            candidatesByPosition.get(view.getPositionId()).add(view);
        }
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
        /* ... keep all your existing CSS styles ... */
        </style>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
    <header>
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 1rem 2rem; background: linear-gradient(135deg, #1e3c72, #2a5298); color: white;">
            <div>
                <h1 style="margin: 0; font-size: 1.5rem;">
                    <i class="fas fa-user-shield"></i> Admin Panel
                </h1>
                <p style="margin: 5px 0 0 0; font-size: 0.9rem; opacity: 0.9;">
                    Logged in as: <%= currentUser != null ? currentUser.getUser_name() : (legacyUserName != null ? legacyUserName : "Administrator") %>
                </p>
            </div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </div>
    </header>
    
    <main>
        <div style="max-width: 1200px; margin: 0 auto; padding: 0 20px;">
            <div class="admin-header">
                <h2>Admin Dashboard</h2>
                <p>Manage candidates, view results, and monitor the voting process</p>
            </div>
            
            <div class="dashboard-cards">
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-users"></i></div>
                    <div class="stats"><%= totalCandidates %></div>
                    <h3 class="card-title">Total Candidates</h3>
                    <p class="card-subtitle">Across all elections</p>
                </div>
                
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-vote-yea"></i></div>
                    <div class="stats"><%= totalVotes %></div>
                    <h3 class="card-title">Total Votes</h3>
                    <p class="card-subtitle"><%= activeElection != null ? "Active election only" : "All time" %></p>
                </div>
                
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-check-circle"></i></div>
                    <div class="stats"><%= turnout %>%</div>
                    <h3 class="card-title">Voter Turnout</h3>
                    <p class="card-subtitle">Eligible students</p>
                </div>
                
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-clock"></i></div>
                    <div class="stats"><%= timeRemaining %></div>
                    <h3 class="card-title">Time Remaining</h3>
                    <p class="card-subtitle"><%= activeElection != null ? activeElection.getElection_name() : "No active election" %></p>
                </div>
            </div>
            
            <div class="admin-actions">
                <a id="add-candidate-btn" class="btn btn-success" href="addCandidate.jsp">
                    <i class="fas fa-user-plus"></i> Add New Candidate
                </a>
                <a href="CandidateListServlet" class="btn">
                    <i class="fas fa-list"></i> Manage Candidates
                </a>
                <a href="resultPage.jsp" class="btn btn-warning">
                    <i class="fas fa-chart-bar"></i> View Results
                </a>
            </div>
            
            <!-- Add Candidate Form -->
            <div id="add-candidate-section" class="admin-section" style="display: none;">
                <h3><i class="fas fa-user-plus"></i> Add New Candidate</h3>
                <p style="color:#666;">Candidates now link to existing students (USERS) and positions for the active election.</p>
                <form id="candidate-form" action="AddCandidateServlet" method="POST">
                    <div class="form-group">
                        <label for="userId"><i class="fas fa-id-card"></i> Student User ID *</label>
                        <input type="number" id="userId" name="userId" class="form-control" required>
                        <small style="color:#666;">Provide the user_id from USERS (role = STUDENT)</small>
                    </div>

                    <div class="form-group">
                        <label for="positionId"><i class="fas fa-briefcase"></i> Position *</label>
                        <select id="positionId" name="positionId" class="form-control" <%= activeElection == null ? "disabled" : "" %> required>
                            <option value="">Select position</option>
                            <% if (positions != null) { 
                                   for (Position pos : positions) { %>
                                <option value="<%= pos.getPosition_id() %>"><%= pos.getPosition_name() %></option>
                            <%   } 
                               } %>
                        </select>
                        <% if (activeElection == null) { %>
                            <small style="color:#d9534f;">No ACTIVE election. Activate one to add candidates.</small>
                        <% } %>
                    </div>

                    <div class="form-group">
                        <label for="manifesto"><i class="fas fa-file-alt"></i> Manifesto *</label>
                        <textarea id="manifesto" name="manifesto" class="form-control" rows="4" required></textarea>
                    </div>

                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn" <%= activeElection == null ? "disabled" : "" %>>
                            <i class="fas fa-save"></i> Add Candidate
                        </button>
                        <button type="button" id="cancel-add-candidate" class="btn" style="background: #6c757d;">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                    </div>
                </form>
            </div>
            
            <!-- Recent Candidates Preview -->
            <div id="candidate-list-section" class="admin-section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                    <h3><i class="fas fa-users"></i> Candidates by Position</h3>
                    <a href="CandidateListServlet" class="btn" style="padding: 8px 16px; font-size: 0.9rem;">
                        <i class="fas fa-external-link-alt"></i> View All
                    </a>
                </div>

                <% if (activeElection == null) { %>
                    <div style="text-align: center; padding: 2rem; color: #666;">
                        <i class="fas fa-ban" style="font-size: 3rem; margin-bottom: 1rem; color: #ddd;"></i>
                        <h4>No active election</h4>
                        <p>Activate an election to see positions and candidates.</p>
                    </div>
                <% } else if (positions == null || positions.isEmpty()) { %>
                    <div style="text-align: center; padding: 2rem; color: #666;">
                        <i class="fas fa-briefcase" style="font-size: 3rem; margin-bottom: 1rem; color: #ddd;"></i>
                        <h4>No positions configured</h4>
                        <p>Add positions for <strong><%= activeElection.getElection_name() %></strong> to start registering candidates.</p>
                    </div>
                <% } else { 
                        int shown = 0;
                        for (Position pos : positions) {
                            List<CandidateView> positionCandidates = candidatesByPosition.get(pos.getPosition_id());
                %>
                    <div style="margin-bottom: 1rem;">
                        <h4 style="margin:0 0 0.5rem 0;"><i class="fas fa-briefcase"></i> <%= pos.getPosition_name() %></h4>
                        <% if (positionCandidates != null && !positionCandidates.isEmpty()) { %>
                            <table class="candidate-table">
                                <thead>
                                    <tr>
                                        <th>Candidate</th>
                                        <th>Email</th>
                                        <th>Manifesto</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (CandidateView view : positionCandidates) { 
                                           if (shown >= 5) { break; }
                                           shown++;
                                    %>
                                        <tr>
                                            <td><%= view.getUserName() %></td>
                                            <td><%= view.getEmail() %></td>
                                            <td><%= view.getManifesto() != null ? view.getManifesto() : "N/A" %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <p style="color:#888; margin:0 0 1rem 0;">No candidates registered for this position yet.</p>
                        <% } %>
                    </div>
                <%  } } %>
            </div>
            
            <!-- Quick Stats -->
            <div class="admin-section">
                <h3><i class="fas fa-chart-line"></i> System Overview</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label>Database Status</label>
                        <p style="color: #28a745; font-weight: bold;">
                            <i class="fas fa-check-circle"></i> Connected
                        </p>
                    </div>
                    <div class="form-group">
                        <label>System Version</label>
                        <p><strong>iVote 1.0</strong></p>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Last Updated</label>
                        <p><strong>Just now</strong></p>
                    </div>
                    <div class="form-group">
                        <label>Admin Actions Today</label>
                        <p><strong>0</strong></p>
                    </div>
                </div>
            </div>
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