<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, java.io.*, java.sql.*"%>
<%
    // Check if user is logged in as admin
    Integer user_id = (Integer) session.getAttribute("user_id");
    String user_name = (String) session.getAttribute("user_name");
    String role = (String) session.getAttribute("role");
    
    if (user_id == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Initialize variables OUTSIDE the POST block
    String election_name = "";
    String start_date = "";
    String end_date = "";
    String status = "";
    String successMessage = "";
    String errorMessage = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        election_name = request.getParameter("election_name");
        start_date = request.getParameter("start_date");
        end_date = request.getParameter("end_date");
        status = request.getParameter("status");
        
        if (election_name == null || election_name.trim().isEmpty()
            || start_date == null || start_date.isEmpty()
            || end_date == null || end_date.isEmpty()
            || status == null || status.isEmpty()) {
            
            errorMessage = "Please fill in all fields.";
        } else {
            Connection conn = null;
            PreparedStatement stmt = null;
            
            try {
                conn = DriverManager.getConnection(
                    "jdbc:derby://localhost:1527/iVoteDB", "app", "app"
                );
                
                String query = "INSERT INTO ELECTION (election_name, start_date, end_date, status) " +
                               "VALUES (?, ?, ?, ?)";
                stmt = conn.prepareStatement(query);
                
                stmt.setString(1, election_name);
                stmt.setDate(2, java.sql.Date.valueOf(start_date));
                stmt.setDate(3, java.sql.Date.valueOf(end_date));
                stmt.setString(4, status);
                
                stmt.executeUpdate();
                
                successMessage = "Election added successfully!";
                
                // Clear form fields after successful submission
                election_name = "";
                start_date = "";
                end_date = "";
                status = "";
                
            } catch (SQLException e) {
                errorMessage = "Error adding election: " + e.getMessage();
                e.printStackTrace();
            } catch (IllegalArgumentException e) {
                errorMessage = "Invalid date format. Please use YYYY-MM-DD format.";
            } finally {
                try { if (stmt != null) stmt.close(); } catch (Exception ex) {}
                try { if (conn != null) conn.close(); } catch (Exception ex) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Add Election - iVote</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="candidate.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1><i class="fas fa-vote-yea"></i> Add Election</h1>
                <p>Create a new election for voting</p>
            </div>
            
            <div class="navigation">
                <a href="adminDashboard.jsp" class="nav-btn">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
                <a href="CandidateListServlet" class="nav-btn">
                    <i class="fas fa-list"></i> View Elections
                </a>
            </div>
            
            <%-- Display Messages --%>
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
                <div class="message success-message">
                    <i class="fas fa-check-circle"></i> <%= successMessage %>
                </div>
            <% } %>
            
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="message error-message">
                    <i class="fas fa-exclamation-triangle"></i> <%= errorMessage %>
                </div>
            <% } %>
            
            <div class="info-card">
                <h3><i class="fas fa-user-shield"></i> Admin Information</h3>
                <div class="user-info-grid">
                    <div class="info-item">
                        <div class="info-label">Admin Name</div>
                        <div class="info-value"><%= user_name %></div>
                    </div>
                </div>
            </div>
            
            <form action="addElections.jsp" method="POST" class="election-form" id="electionForm">
                <div class="form-group">
                    <label for="election_name">Election Name <span class="required">*</span></label>
                    <input type="text" id="election_name" name="election_name" 
                           placeholder="Enter election name (e.g., Student Council Election 2024)"
                           value="<%= election_name != null ? election_name : "" %>" 
                           required>
                </div>
                
                <div class="form-row">
                    <div class="form-group half">
                        <label for="start_date">Start Date <span class="required">*</span></label>
                        <input type="date" id="start_date" name="start_date" 
                               value="<%= start_date != null ? start_date : "" %>" 
                               required>
                        <small class="hint">Election voting opens on this date</small>
                    </div>
                    
                    <div class="form-group half">
                        <label for="end_date">End Date <span class="required">*</span></label>
                        <input type="date" id="end_date" name="end_date" 
                               value="<%= end_date != null ? end_date : "" %>" 
                               required>
                        <small class="hint">Election voting closes on this date</small>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="status">Status <span class="required">*</span></label>
                    <select id="status" name="status" required>
                        <option value="">-- Select Status --</option>
                        <option value="ACTIVE" <%= "ACTIVE".equals(status) ? "selected" : "" %>>ACTIVE</option>
                        <option value="UPCOMING" <%= "UPCOMING".equals(status) ? "selected" : "" %>>UPCOMING</option>
                        <option value="CLOSED" <%= "CLOSED".equals(status) ? "selected" : "" %>>CLOSED</option>
                    </select>
                    <small class="hint">Set election status (ACTIVE elections are open for voting)</small>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="submit-btn">
                        <i class="fas fa-plus-circle"></i> Add Election
                    </button>
                    <button type="reset" class="cancel-btn">
                        <i class="fas fa-undo"></i> Reset Form
                    </button>
                </div>
            </form>
            
            <div class="info-box">
                <h4><i class="fas fa-info-circle"></i> Important Notes:</h4>
                <ul>
                    <li>Election dates cannot be changed once created</li>
                    <li>Only one election can be ACTIVE at a time</li>
                    <li>Candidates must be assigned to a specific election</li>
                    <li>Voters can only vote in ACTIVE elections</li>
                </ul>
            </div>
            
            <script>
                // Auto-hide messages after 5 seconds
                setTimeout(function() {
                    var messages = document.querySelectorAll('.message');
                    messages.forEach(function(msg) {
                        msg.style.transition = 'opacity 0.5s';
                        msg.style.opacity = '0';
                        setTimeout(function() {
                            if (msg.parentNode) {
                                msg.parentNode.removeChild(msg);
                            }
                        }, 500);
                    });
                }, 5000);
                
                // Date validation
                document.getElementById('electionForm').addEventListener('submit', function(e) {
                    var startDate = new Date(document.getElementById('start_date').value);
                    var endDate = new Date(document.getElementById('end_date').value);
                    var today = new Date();
                    
                    // Clear previous errors
                    document.getElementById('start_date').style.borderColor = '#ddd';
                    document.getElementById('end_date').style.borderColor = '#ddd';
                    
                    var isValid = true;
                    
                    // Check if start date is in the future
                    if (startDate < today) {
                        document.getElementById('start_date').style.borderColor = '#dc3545';
                        alert('Start date must be today or in the future.');
                        isValid = false;
                    }
                    
                    // Check if end date is after start date
                    if (endDate <= startDate) {
                        document.getElementById('end_date').style.borderColor = '#dc3545';
                        alert('End date must be after start date.');
                        isValid = false;
                    }
                    
                    if (!isValid) {
                        e.preventDefault();
                    }
                });
                
                // Set minimum date to today
                var today = new Date().toISOString().split('T')[0];
                document.getElementById('start_date').min = today;
                
                // Update end date min based on start date
                document.getElementById('start_date').addEventListener('change', function() {
                    document.getElementById('end_date').min = this.value;
                });
            </script>
        </div>
    </body>
</html>