<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, java.io.*, java.sql.*, java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in as admin
    Integer admin_id = (Integer) session.getAttribute("user_id");
    String user_name = (String) session.getAttribute("user_name");
    String role = (String) session.getAttribute("role");
    
    if (admin_id == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    // Initialize variables based on your ACTUAL database schema
    String candidate_id = "";
    String candidate_name = "";
    String faculty = "";
    String email = "";
    String manifesto = "";
    String election_id = "";
    String user_id_db = ""; // user_id from candidates table
    
    String successMessage = "";
    String errorMessage = "";
    
    // Load candidate data from database on GET request
    if ("GET".equalsIgnoreCase(request.getMethod())) {
        candidate_id = request.getParameter("candidate_id");
        
        if (candidate_id != null && !candidate_id.trim().isEmpty()) {
            try {
                Class.forName("org.apache.derby.jdbc.ClientDriver");
                conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
                String query = "SELECT * FROM CANDIDATES WHERE CANDIDATE_ID = ?";
                stmt = conn.prepareStatement(query);
                stmt.setInt(1, Integer.parseInt(candidate_id.trim()));
                rs = stmt.executeQuery();
                
                if (rs.next()) {
                    candidate_name = rs.getString("CANDIDATE_NAME");
                    faculty = rs.getString("FACULTY");
                    email = rs.getString("EMAIL");
                    manifesto = rs.getString("MANIFESTO");
                    election_id = rs.getString("ELECTION_ID");
                    user_id_db = rs.getString("USER_ID");
                } else {
                    errorMessage = "Candidate not found!";
                }
            } catch (Exception e) {
                errorMessage = "Error loading candidate: " + e.getMessage();
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        }
    }
    
    // Handle POST request (form submission)
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        candidate_id = request.getParameter("candidate_id");
        candidate_name = request.getParameter("candidate_name");
        faculty = request.getParameter("faculty");
        email = request.getParameter("email");
        manifesto = request.getParameter("manifesto");
        
        if (candidate_id == null || candidate_id.trim().isEmpty() ||
            candidate_name == null || candidate_name.trim().isEmpty() ||
            faculty == null || faculty.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            manifesto == null || manifesto.trim().isEmpty()) {
            
            errorMessage = "All fields are required!";
        } else {
            try {
                Class.forName("org.apache.derby.jdbc.ClientDriver");
                conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
                
                // UPDATE query based on your ACTUAL database schema
                String query = "UPDATE CANDIDATES SET CANDIDATE_NAME=?, FACULTY=?, EMAIL=?, MANIFESTO=? WHERE CANDIDATE_ID=?";
                
                stmt = conn.prepareStatement(query);
                stmt.setString(1, candidate_name.trim());
                stmt.setString(2, faculty.trim());
                stmt.setString(3, email.trim());
                stmt.setString(4, manifesto.trim());
                stmt.setInt(5, Integer.parseInt(candidate_id.trim()));
                
                int rowsUpdated = stmt.executeUpdate();
                if (rowsUpdated > 0) {
                    successMessage = "Candidate updated successfully!";
                } else {
                    errorMessage = "Failed to update candidate. Please try again.";
                }
            } catch (Exception e) {
                errorMessage = "Error updating candidate: " + e.getMessage();
                e.printStackTrace();
            } finally {
                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Update Candidate - iVote</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="candidate.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            .info-card {
                background: #f8f9fa;
                border-radius: 8px;
                padding: 20px;
                margin-bottom: 20px;
                border-left: 4px solid #4a6baf;
            }
            .info-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 15px;
                margin-top: 15px;
            }
            .info-item {
                padding: 10px;
                background: white;
                border-radius: 6px;
                border: 1px solid #dee2e6;
            }
            .info-label {
                font-weight: bold;
                color: #4a6baf;
                font-size: 12px;
                margin-bottom: 5px;
                text-transform: uppercase;
            }
            .info-value {
                color: #333;
                font-size: 14px;
            }
            .readonly-field {
                background-color: #e9ecef;
                cursor: not-allowed;
                opacity: 0.8;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1><i class="fas fa-user-edit"></i> Update Candidate</h1>
                <p>Modify candidate information and details</p>
            </div>
            
            <div class="navigation">
                <a href="CandidateListServlet" class="nav-btn">
                    <i class="fas fa-arrow-left"></i> Back to Candidate List
                </a>
                <a href="adminDashboard.jsp" class="nav-btn">
                    <i class="fas fa-home"></i> Dashboard
                </a>
            </div>
            
            <!-- Display Messages -->
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
            
            <!-- Admin Information -->
            <div class="info-card">
                <h3><i class="fas fa-user-shield"></i> Admin Information</h3>
                <div class="user-info-grid">
                    <div class="info-item">
                        <div class="info-label">Admin Name</div>
                        <div class="info-value"><%= user_name %></div>
                    </div>
                </div>
            </div>
            
            <!-- Update Form -->
            <form action="updateCandidate.jsp" method="post" id="candidateForm">
                <input type="hidden" name="candidate_id" value="<%= candidate_id %>">
                
                <div class="form-group">
                    <label for="candidate_name">Candidate Name <span class="required">*</span></label>
                    <input type="text" id="candidate_name" name="candidate_name" 
                           placeholder="Enter candidate name" 
                           value="<%= candidate_name != null ? candidate_name : "" %>" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="faculty">Faculty <span class="required">*</span></label>
                    <input type="text" id="faculty" name="faculty" 
                           placeholder="Enter faculty/department" 
                           value="<%= faculty != null ? faculty : "" %>" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email <span class="required">*</span></label>
                    <input type="email" id="email" name="email" 
                           placeholder="Enter email address" 
                           value="<%= email != null ? email : "" %>" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="manifesto">Manifesto <span class="required">*</span></label>
                    <textarea id="manifesto" name="manifesto" 
                              placeholder="Describe the candidate's campaign platform, vision, and promises..."
                              rows="6" 
                              required><%= manifesto != null ? manifesto : "" %></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="submit-btn">
                        <i class="fas fa-save"></i> Update Candidate
                    </button>
                </div>
            </form>
            
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
                
                // Disable form submission if required fields are empty
                document.getElementById('candidateForm').addEventListener('submit', function(e) {
                    var requiredFields = this.querySelectorAll('[required]');
                    var isValid = true;
                    
                    requiredFields.forEach(function(field) {
                        if (!field.value.trim()) {
                            isValid = false;
                            field.style.borderColor = '#dc3545';
                        } else {
                            field.style.borderColor = '#ddd';
                        }
                    });
                    
                    if (!isValid) {
                        e.preventDefault();
                        alert('Please fill in all required fields.');
                    }
                });
            </script>
        </div>
    </body>
</html>