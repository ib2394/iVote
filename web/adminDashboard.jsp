<%-- 
    Document   : adminDashboard
    Created on : 20 Jan, 2026, 8:30:42 PM
    Author     : USER
--%>

<%@page import="com.java.bean.Candidate"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="dao.CandidateDAO" %>
<%@page import="bean.Candidate" %>
<%@page import="java.util.List" %>
<%
    // Check if admin is logged in
    String adminID = (String) session.getAttribute("adminID");
    if (adminID == null) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
    
    // Get candidates from database
    CandidateDAO candidateDAO = new CandidateDAO();
    List<Candidate> candidates = candidateDAO.getAllCandidates();
    int totalCandidates = candidateDAO.getTotalCandidates();
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
                    Logged in as: <%= session.getAttribute("adminName") != null ? session.getAttribute("adminName") : "Administrator" %>
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
                    <p class="card-subtitle">Across all faculties</p>
                </div>
                
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-vote-yea"></i></div>
                    <div class="stats">
                        <% 
                            // You can add vote counting logic here
                            out.print("0"); // Placeholder
                        %>
                    </div>
                    <h3 class="card-title">Total Votes</h3>
                    <p class="card-subtitle">Cast by students</p>
                </div>
                
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-check-circle"></i></div>
                    <div class="stats">0%</div>
                    <h3 class="card-title">Voter Turnout</h3>
                    <p class="card-subtitle">Of eligible students</p>
                </div>
                
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-clock"></i></div>
                    <div class="stats">--</div>
                    <h3 class="card-title">Time Remaining</h3>
                    <p class="card-subtitle">Until voting ends</p>
                </div>
            </div>
            
            <div class="admin-actions">
                <button id="add-candidate-btn" class="btn btn-success">
                    <i class="fas fa-user-plus"></i> Add New Candidate
                </button>
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
                <form id="candidate-form" action="AddCandidateServlet" method="POST" enctype="multipart/form-data">
                    <div class="form-group">
                        <label for="candidateName"><i class="fas fa-user"></i> Candidate Name *</label>
                        <input type="text" id="candidateName" name="candidateName" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="candidateEmail"><i class="fas fa-envelope"></i> Candidate Email *</label>
                        <input type="email" id="candidateEmail" name="candidateEmail" class="form-control" required>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="program"><i class="fas fa-graduation-cap"></i> Program</label>
                            <input type="text" id="program" name="program" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="faculty"><i class="fas fa-university"></i> Faculty *</label>
                            <select id="faculty" name="faculty" class="form-control" required>
                                <option value="">Select Faculty</option>
                                <option value="Faculty of Computer and Mathematical Sciences">Faculty of Computer and Mathematical Sciences</option>
                                <option value="Faculty of Electrical Engineering">Faculty of Electrical Engineering</option>
                                <option value="Faculty of Mechanical Engineering">Faculty of Mechanical Engineering</option>
                                <option value="Faculty of Civil Engineering">Faculty of Civil Engineering</option>
                                <option value="Faculty of Business Management">Faculty of Business Management</option>
                                <option value="Faculty of Accountancy">Faculty of Accountancy</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="desc"><i class="fas fa-file-alt"></i> Description *</label>
                        <textarea id="desc" name="desc" class="form-control" rows="4" required></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="candidatePic"><i class="fas fa-camera"></i> Candidate Picture</label>
                        <input type="file" id="candidatePic" name="candidatePic" class="form-control" accept="image/*">
                        <small style="color: #666;">Optional. Max 10MB. Supported: JPG, PNG, GIF</small>
                    </div>
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn">
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
                    <h3><i class="fas fa-users"></i> Recent Candidates</h3>
                    <a href="CandidateListServlet" class="btn" style="padding: 8px 16px; font-size: 0.9rem;">
                        <i class="fas fa-external-link-alt"></i> View All
                    </a>
                </div>
                
                <% if (candidates != null && !candidates.isEmpty()) { %>
                    <table class="candidate-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Program</th>
                                <th>Faculty</th>
                                <th>Email</th>
                                <th>Added By</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                // Show only first 5 candidates for preview
                                int count = 0;
                                for (Candidate candidate : candidates) {
                                    if (count >= 5) break;
                            %>
                                <tr>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 10px;">
                                            <% if (candidate.getCandidatePic() != null && !candidate.getCandidatePic().isEmpty()) { %>
                                                <img src="<%= candidate.getCandidatePic() %>" 
                                                     alt="<%= candidate.getCandidateName() %>" 
                                                     style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;">
                                            <% } else { %>
                                                <div style="width: 40px; height: 40px; border-radius: 50%; background: #f0f0f0; display: flex; align-items: center; justify-content: center;">
                                                    <i class="fas fa-user" style="color: #666;"></i>
                                                </div>
                                            <% } %>
                                            <%= candidate.getCandidateName() %>
                                        </div>
                                    </td>
                                    <td><%= candidate.getProgram() != null ? candidate.getProgram() : "N/A" %></td>
                                    <td><%= candidate.getFaculty() %></td>
                                    <td><%= candidate.getCandidateEmail() %></td>
                                    <td><%= candidate.getAdminID() != null ? candidate.getAdminID() : "System" %></td>
                                    <td>
                                        <a href="editCandidate.jsp?id=<%= candidate.getCandidateID() %>" 
                                           class="action-btn edit-btn">
                                            <i class="fas fa-edit"></i> Edit
                                        </a>
                                        <a href="DeleteCandidateServlet?id=<%= candidate.getCandidateID() %>" 
                                           class="action-btn delete-btn"
                                           onclick="return confirm('Delete <%= candidate.getCandidateName() %>?')">
                                            <i class="fas fa-trash"></i> Delete
                                        </a>
                                    </td>
                                </tr>
                            <% 
                                    count++;
                                } 
                            %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div style="text-align: center; padding: 2rem; color: #666;">
                        <i class="fas fa-users-slash" style="font-size: 3rem; margin-bottom: 1rem; color: #ddd;"></i>
                        <h4>No Candidates Yet</h4>
                        <p>Start by adding your first candidate</p>
                        <button id="add-first-candidate" class="btn" style="margin-top: 1rem;">
                            <i class="fas fa-user-plus"></i> Add First Candidate
                        </button>
                    </div>
                <% } %>
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