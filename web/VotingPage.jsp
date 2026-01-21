<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="bean.Users"%>
<%@page import="bean.Election"%>
<%@page import="bean.Position"%>
<%@page import="bean.CandidateView"%>
<%@page import="dao.ElectionDAO"%>
<%@page import="dao.PositionDAO"%>
<%@page import="dao.CandidateDAO"%>
<%@page import="dao.VoteDAO"%>
<%@page import="java.util.*"%>
<%
    Users currentUser = (Users) session.getAttribute("user");
    String legacyRole = (String) session.getAttribute("role");
    String legacyUserName = (String) session.getAttribute("userName");

    // Accept either new auth (Users in session) OR legacy auth (role string in session).
    // NOTE: voting requires a real Users record (user_id). If legacy username looks like an email, hydrate it.
    if (currentUser == null) {
        if (legacyRole == null || !"student".equalsIgnoreCase(legacyRole)) {
            response.sendRedirect("login.jsp");
            return;
        }
    } else {
        if (!"STUDENT".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
    }

    ElectionDAO electionDAO = new ElectionDAO();
    PositionDAO positionDAO = new PositionDAO();
    CandidateDAO candidateDAO = new CandidateDAO();
    VoteDAO voteDAO = new VoteDAO();
    dao.UserDAO userDAO = new dao.UserDAO();
    if (currentUser == null && legacyUserName != null && legacyUserName.indexOf("@") > 0) {
        Users maybe = userDAO.getUserByEmail(legacyUserName);
        if (maybe != null) {
            currentUser = maybe;
            session.setAttribute("user", currentUser);
        }
    }

    Election activeElection = electionDAO.getActiveElection();
    List<Position> positions = null;
    if (activeElection != null) {
        positions = positionDAO.getPositionsByElection(activeElection.getElection_id());
    } else {
        positions = new ArrayList<Position>();
    }

    Map<Integer, Boolean> votedPositions = new HashMap<Integer, Boolean>();
    for (Position pos : positions) {
        if (currentUser != null) {
            votedPositions.put(pos.getPosition_id(), voteDAO.hasVotedForPosition(currentUser.getUser_id(), pos.getPosition_id()));
        } else {
            votedPositions.put(pos.getPosition_id(), Boolean.FALSE);
        }
    }

    String voteStatus = request.getParameter("vote");
    String errorStatus = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Voting Page</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        header { color: white; padding: 1rem 0; background: linear-gradient(135deg, #1e3c72, #2a5298); }
        .header-content { display: flex; justify-content: space-between; align-items: center; max-width: 1100px; margin: 0 auto; padding: 0 1.5rem; }
        .logo { display: flex; align-items: center; gap: 10px; }
        .logo h1 { font-size: 1.6rem; }
        .user-info { display: flex; align-items: center; gap: 10px; }
        nav ul { display: flex; list-style: none; gap: 15px; }
        nav a { color: white; text-decoration: none; font-weight: 500; padding: 5px 10px; border-radius: 4px; transition: background-color 0.3s; }
        nav a:hover { background: rgba(255,255,255,0.15); }
        main { padding: 2rem 0; min-height: calc(100vh - 150px); background: #f5f7fb; }
        .voting-container { max-width: 1100px; margin: 0 auto; background-color: white; padding: 2rem; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .voting-header { text-align: center; margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px solid #eee; }
        .status-pill { display: inline-block; padding: 6px 12px; border-radius: 999px; font-size: 0.85rem; }
        .pill-active { background: #e8f5e9; color: #2e7d32; }
        .pill-closed { background: #fdecea; color: #c62828; }
        .alert { padding: 12px 16px; border-radius: 6px; margin: 10px 0; }
        .alert-success { background: #e8f5e9; color: #2e7d32; }
        .alert-error { background: #fdecea; color: #c62828; }
        .candidates-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 1.2rem; margin-bottom: 2rem; }
        .candidate-card { background-color: white; border-radius: 8px; padding: 1.2rem; text-align: center; border: 2px solid #f0f0f0; transition: all 0.3s; }
        .candidate-card:hover { border-color: #1e3c72; box-shadow: 0 3px 12px rgba(0,0,0,0.08); }
        .candidate-name { font-size: 1.2rem; font-weight: 600; margin-bottom: 0.3rem; color: #1e3c72; }
        .candidate-desc { font-size: 0.9rem; color: #777; margin-bottom: 1rem; height: 60px; overflow: hidden; }
        .vote-btn { background: linear-gradient(135deg, #28a745, #20c997); color: white; border: none; padding: 10px 14px; border-radius: 4px; cursor: pointer; font-weight: 600; width: 100%; transition: all 0.3s; }
        .vote-btn:disabled { background: #ccc; cursor: not-allowed; }
        .btn { display: inline-block; background: linear-gradient(135deg, #1e3c72, #2a5298); color: white; padding: 10px 22px; border: none; border-radius: 5px; font-weight: 600; cursor: pointer; text-decoration: none; transition: all 0.3s ease; }
        .muted { color: #777; font-size: 0.95rem; }
        footer { background-color: #1e3c72; color: white; text-align: center; padding: 1.5rem 0; margin-top: 2rem; }
        @media (max-width: 768px) { .header-content { flex-direction: column; gap: 1rem; } .candidates-list { grid-template-columns: 1fr; } }
        </style>
    </head>
    <body>
    <header>
        <div class="header-content">
            <div class="logo">
                <i class="fas fa-check-circle logo-icon"></i>
                <div>
                    <h1>Voting</h1>
                    <p class="muted">Logged in as <strong><%= currentUser.getUser_name() %></strong></p>
                </div>
            </div>
            <nav>
                <ul>
                    <li><a href="index.html">Home</a></li>
                    <li><a href="resultPage.jsp">Results</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <main>
        <div class="voting-container">
            <div class="voting-header">
                <% if (activeElection != null) { %>
                    <p class="status-pill pill-active"><i class="fas fa-bolt"></i> Active Election</p>
                    <h2><%= activeElection.getElection_name() %></h2>
                    <p>Select your preferred candidate for each position.</p>
                <% } else { %>
                    <p class="status-pill pill-closed"><i class="fas fa-ban"></i> No Active Election</p>
                    <h2>Voting unavailable</h2>
                    <p class="muted">Please check back later.</p>
                <% } %>
            </div>

            <% if ("success".equals(voteStatus)) { %>
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> Vote recorded successfully.</div>
            <% } else if ("failed".equals(voteStatus)) { %>
                <div class="alert alert-error"><i class="fas fa-times-circle"></i> Unable to record vote. Please try again.</div>
            <% } else if (errorStatus != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> <%= errorStatus %></div>
            <% } %>

            <% if (activeElection == null) { %>
                <div style="text-align:center; padding:2rem;">
                    <i class="fas fa-calendar-times" style="font-size:3rem; color:#ddd;"></i>
                    <p class="muted" style="margin-top:1rem;">No election is currently active.</p>
                    <a class="btn" href="index.html" style="margin-top:1rem;">Back to Home</a>
                </div>
            <% } else if (positions == null || positions.isEmpty()) { %>
                <div style="text-align:center; padding:2rem;">
                    <i class="fas fa-briefcase" style="font-size:3rem; color:#ddd;"></i>
                    <p class="muted" style="margin-top:1rem;">No positions have been configured for this election.</p>
                </div>
            <% } else { 
                    for (Position pos : positions) { 
                        List<CandidateView> candidates = candidateDAO.getCandidateViewsByPosition(pos.getPosition_id());
                        boolean alreadyVoted = votedPositions.getOrDefault(pos.getPosition_id(), false);
            %>
                <section style="margin-bottom:2rem;">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:0.5rem;">
                        <h3 style="margin:0;"><i class="fas fa-briefcase"></i> <%= pos.getPosition_name() %></h3>
                        <span class="muted"><%= alreadyVoted ? "You have voted for this position" : "1 vote allowed" %></span>
                    </div>
                    <% if (candidates == null || candidates.isEmpty()) { %>
                        <p class="muted">No candidates registered for this position.</p>
                    <% } else { %>
                        <div class="candidates-list">
                            <% for (CandidateView view : candidates) { %>
                                <div class="candidate-card">
                                    <h3 class="candidate-name"><%= view.getUserName() %></h3>
                                    <p class="muted" style="margin-bottom:0.3rem;"><%= view.getEmail() %></p>
                                    <p class="candidate-desc"><%= view.getManifesto() != null ? view.getManifesto() : "No manifesto submitted." %></p>
                                    <form method="post" action="VotingServlet">
                                        <input type="hidden" name="candidateId" value="<%= view.getCandidateId() %>">
                                        <input type="hidden" name="positionId" value="<%= view.getPositionId() %>">
                                        <button class="vote-btn" type="submit" <%= alreadyVoted ? "disabled" : "" %>>
                                            <i class="fas fa-vote-yea"></i> <%= alreadyVoted ? "Already Voted" : "Vote" %>
                                        </button>
                                    </form>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </section>
            <%  } } %>
        </div>
    </main>

    <footer>
        <p>Thank you for participating in the election.</p>
    </footer>
    </body>
</html>
