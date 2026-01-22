<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Check if user is logged in as admin
    Integer user_id = (Integer) session.getAttribute("user_id");
    String user_name = (String) session.getAttribute("user_name");
    String role = (String) session.getAttribute("role");
    
    if (user_id == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get success/error messages
    String message = request.getParameter("message");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Candidate List - iVote</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="candidate.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            .candidates-container {
                margin-top: 20px;
            }
            .candidates-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                gap: 20px;
                margin-top: 20px;
            }
            .candidate-card {
                background: white;
                border-radius: 10px;
                padding: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                transition: transform 0.3s, box-shadow 0.3s;
                border-left: 4px solid #4a6baf;
            }
            .candidate-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            }
            .candidate-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                margin-bottom: 15px;
            }
            .candidate-name {
                font-size: 18px;
                font-weight: bold;
                color: #2c3e50;
                margin-bottom: 5px;
            }
            .candidate-id {
                font-size: 12px;
                color: #7f8c8d;
                background: #f8f9fa;
                padding: 2px 8px;
                border-radius: 12px;
            }
            .candidate-info {
                margin: 10px 0;
                font-size: 14px;
                color: #555;
            }
            .candidate-info-item {
                display: flex;
                align-items: center;
                margin-bottom: 8px;
            }
            .candidate-info-item i {
                width: 20px;
                color: #4a6baf;
                margin-right: 8px;
            }
            .manifesto-preview {
                background: #f8f9fa;
                padding: 10px;
                border-radius: 5px;
                margin: 15px 0;
                font-size: 13px;
                color: #666;
                max-height: 100px;
                overflow-y: auto;
                border-left: 3px solid #4a6baf;
            }
            .candidate-actions {
                display: flex;
                gap: 10px;
                margin-top: 15px;
                padding-top: 15px;
                border-top: 1px solid #eee;
            }
            .action-btn {
                padding: 8px 15px;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                font-size: 13px;
                display: flex;
                align-items: center;
                gap: 5px;
                text-decoration: none;
                transition: all 0.3s;
            }
            .edit-btn {
                background-color: #3498db;
                color: white;
            }
            .edit-btn:hover {
                background-color: #2980b9;
            }
            .delete-btn {
                background-color: #e74c3c;
                color: white;
            }
            .delete-btn:hover {
                background-color: #c0392b;
            }
            .empty-state {
                text-align: center;
                padding: 40px;
                background: #f8f9fa;
                border-radius: 10px;
                color: #7f8c8d;
            }
            .empty-state i {
                font-size: 48px;
                margin-bottom: 20px;
                color: #bdc3c7;
            }
            .search-filter {
                display: flex;
                gap: 15px;
                margin-bottom: 20px;
                background: white;
                padding: 15px;
                border-radius: 8px;
                box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            }
            .search-box {
                flex: 1;
                position: relative;
            }
            .search-box input {
                width: 100%;
                padding: 10px 15px 10px 40px;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 14px;
            }
            .search-box i {
                position: absolute;
                left: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #7f8c8d;
            }
            .filter-select {
                padding: 10px 15px;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 14px;
                background: white;
                min-width: 150px;
            }
            .stats-card {
                background: linear-gradient(135deg, #4a6baf 0%, #2c3e50 100%);
                color: white;
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 20px;
            }
            .stats-content {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .stats-number {
                font-size: 36px;
                font-weight: bold;
            }
            .stats-label {
                font-size: 14px;
                opacity: 0.9;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1><i class="fas fa-users"></i> Candidate List</h1>
                <p>View and manage all registered candidates</p>
            </div>
            
            <div class="navigation">
                <a href="adminDashboard.jsp" class="nav-btn">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
                <a href="addCandidate.jsp" class="nav-btn">
                    <i class="fas fa-user-plus"></i> Add New Candidate
                </a>
            </div>
            
            <!-- Display Messages -->
            <% if (message != null && !message.isEmpty()) { %>
                <div class="message success-message">
                    <i class="fas fa-check-circle"></i> ${param.message}
                </div>
            <% } %>
            
            <% if (error != null && !error.isEmpty()) { %>
                <div class="message error-message">
                    <i class="fas fa-exclamation-triangle"></i> ${param.error}
                </div>
            <% } %>
            
            <!-- Stats Card -->
            <div class="stats-card">
                <div class="stats-content">
                    <div>
                        <div class="stats-number">${candidates.size()}</div>
                        <div class="stats-label">Total Candidates</div>
                    </div>
                    <i class="fas fa-chart-bar" style="font-size: 48px; opacity: 0.8;"></i>
                </div>
            </div>
            
            <!-- Search and Filter -->
            <div class="search-filter">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Search candidates by name, faculty, or email...">
                </div>
                <select class="filter-select" id="facultyFilter">
                    <option value="">All Faculties</option>
                    <option value="Engineering">Engineering</option>
                    <option value="Science">Science</option>
                    <option value="Business">Business</option>
                    <option value="Arts">Arts</option>
                    <!-- Add more faculty options -->
                </select>
            </div>
            
            <!-- Candidates Grid -->
            <div class="candidates-container">
                <c:choose>
                    <c:when test="${not empty candidates}">
                        <div class="candidates-grid" id="candidatesGrid">
                            <c:forEach var="candidate" items="${candidates}">
                                <div class="candidate-card" data-faculty="${candidate.faculty}">
                                    <div class="candidate-header">
                                        <div>
                                            <div class="candidate-name">${candidate.candidate_name}</div>
                                            <div class="candidate-id">ID: ${candidate.candidate_id}</div>
                                        </div>
                                    </div>
                                    
                                    <div class="candidate-info">
                                        <div class="candidate-info-item">
                                            <i class="fas fa-university"></i>
                                            ${candidate.faculty}
                                        </div>
                                        <div class="candidate-info-item">
                                            <i class="fas fa-envelope"></i>
                                            ${candidate.email}
                                        </div>
                                        <c:if test="${not empty candidate.election_id}">
                                            <div class="candidate-info-item">
                                                <i class="fas fa-vote-yea"></i>
                                                Election ID: ${candidate.election_id}
                                            </div>
                                        </c:if>
                                    </div>
                                    
                                    <c:if test="${not empty candidate.manifesto}">
                                        <div class="manifesto-preview" title="${candidate.manifesto}">
                                            <strong>Manifesto:</strong> 
                                            ${candidate.manifesto.length() > 150 ? 
                                                candidate.manifesto.substring(0, 150) + '...' : 
                                                candidate.manifesto}
                                        </div>
                                    </c:if>
                                    
                                    <div class="candidate-actions">
                                        <a href="updateCandidate.jsp?candidate_id=${candidate.candidate_id}" 
                                           class="action-btn edit-btn">
                                            <i class="fas fa-edit"></i> Edit
                                        </a>
                                        <a href="DeleteCandidateServlet?candidate_id=${candidate.candidate_id}" 
                                           class="action-btn delete-btn"
                                           onclick="return confirm('Are you sure you want to delete this candidate?');">
                                            <i class="fas fa-trash"></i> Delete
                                        </a>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <i class="fas fa-user-slash"></i>
                            <h3>No Candidates Found</h3>
                            <p>There are no candidates registered yet. Add your first candidate to get started.</p>
                            <a href="addCandidate.jsp" class="submit-btn" style="margin-top: 20px;">
                                <i class="fas fa-user-plus"></i> Add First Candidate
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
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
                
                // Search functionality
                document.getElementById('searchInput').addEventListener('keyup', function() {
                    var searchTerm = this.value.toLowerCase();
                    var cards = document.querySelectorAll('.candidate-card');
                    
                    cards.forEach(function(card) {
                        var text = card.textContent.toLowerCase();
                        if (text.includes(searchTerm)) {
                            card.style.display = 'block';
                        } else {
                            card.style.display = 'none';
                        }
                    });
                });
                
                // Filter by faculty
                document.getElementById('facultyFilter').addEventListener('change', function() {
                    var selectedFaculty = this.value;
                    var cards = document.querySelectorAll('.candidate-card');
                    
                    cards.forEach(function(card) {
                        var faculty = card.getAttribute('data-faculty');
                        if (!selectedFaculty || faculty === selectedFaculty) {
                            card.style.display = 'block';
                        } else {
                            card.style.display = 'none';
                        }
                    });
                });
            </script>
        </div>
    </body>
</html>