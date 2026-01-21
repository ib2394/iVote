<%-- 
    Document   : viewCandidates
    Created on : 20 Jan, 2026, 8:40:12 PM
    Author     : USER
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>View Candidate List - iVote</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <div class="container">
        <header>
            <h1>Candidate List</h1>
            <p>View all registered candidates</p>
        </header>
        
        <div class="nav-buttons">
            <a href="adminDashboard.html" class="nav-button">← Back to Dashboard</a>
            <a href="addCandidate.jsp" class="nav-button">Add New Candidate</a>
        </div>
        
        <div class="candidates-container">
            <c:choose>
                <c:when test="${not empty candidates}">
                    <table>
                        <thead>
                            <tr>
                                <th>Photo</th>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Program</th>
                                <th>Faculty</th>
                                <th>Description</th>
                                <th>Admin ID</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                    </table>
                    
                    <!-- Pagination (if needed) -->
                    <div style="margin-top: 2rem; text-align: center;">
                        <button style="padding: 8px 16px; margin: 0 4px; background: #667eea; color: white; border: none; border-radius: 4px; cursor: pointer;">1</button>
                        <button style="padding: 8px 16px; margin: 0 4px; background: #f0f0f0; color: #333; border: none; border-radius: 4px; cursor: pointer;">2</button>
                        <button style="padding: 8px 16px; margin: 0 4px; background: #f0f0f0; color: #333; border: none; border-radius: 4px; cursor: pointer;">3</button>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="no-candidates">
                        <h3>No Candidates Found</h3>
                        <p>No candidates have been registered yet. Start by adding the first candidate.</p>
                        <a href="addCandidate.jsp" class="nav-button" style="display: inline-block; margin-top: 1.5rem;">Add First Candidate</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    
    <script>
        function editCandidate(candidateID) {
            if (confirm('Edit candidate with ID: ' + candidateID + '?')) {
                // This will redirect to edit page with candidate ID
                window.location.href = 'editCandidate.jsp?id=' + candidateID;
            }
        }
        
        function deleteCandidate(candidateID, candidateName) {
            if (confirm('Are you sure you want to delete candidate: ' + candidateName + '?\n\nThis action cannot be undone.')) {
                // This will call delete servlet with candidate ID
                window.location.href = 'DeleteCandidateServlet?candidateID=' + candidateID;
            }
        }
        
        // Show full description on click
        document.querySelectorAll('.desc-cell').forEach(cell => {
            cell.addEventListener('click', function() {
                if (this.style.whiteSpace === 'nowrap') {
                    this.style.whiteSpace = 'normal';
                    this.style.overflow = 'visible';
                } else {
                    this.style.whiteSpace = 'nowrap';
                    this.style.overflow = 'hidden';
                }
            });
        });
        
    </script>
</body>
</html>