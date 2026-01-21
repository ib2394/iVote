<%-- 
    Document   : addCandidate
    Created on : 20 Jan, 2026, 8:35:16 PM
    Author     : USER
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="dao.PositionDAO,dao.ElectionDAO,bean.Election,bean.Position,java.util.List" %>
<%
    ElectionDAO electionDAO = new ElectionDAO();
    Election activeElection = electionDAO.getActiveElection();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add New Candidate - iVote</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>Add New Candidate</h1>
    <p>Register a user as a candidate by providing their USER_ID, and a manifesto.</p>
    
    <div>
        <a href="adminDashboard.jsp">Back to Dashboard</a>
        <a href="CandidateListServlet">View Candidate List</a>
    </div>
    
    <%-- Show feedback messages from the session --%>
    <c:if test="${not empty sessionScope.successMessage}">
        <div style="color: green;">${sessionScope.successMessage}</div>
        <%
            session.removeAttribute("successMessage");
        %>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div style="color: red;">${sessionScope.errorMessage}</div>
        <%
            session.removeAttribute("errorMessage");
        %>
    </c:if>
    
    <form action="AddCandidateServlet" method="post" id="candidateForm">
        <div>
            <label for="userId">User ID *</label>
            <input type="number" id="userId" name="userId" min="1" required placeholder="Enter existing USER_ID">
            <small>System will fetch the user's name/email from USERS for display.</small>
        </div>
        
        <div>
            <label for="manifesto">Manifesto *</label>
            <textarea id="manifesto" name="manifesto" rows="6" required 
                      placeholder="Describe the candidate's campaign platform, vision, and promises"></textarea>
        </div>
        
        <button type="submit" <%= activeElection == null ? "disabled" : "" %>>Register Candidate</button>
    </form>
    
    <script>
        document.getElementById('candidateForm').addEventListener('submit', function(e) {
            const userId = document.getElementById('userId').value.trim();
            const manifesto = document.getElementById('manifesto').value.trim();

            if (userId === "") {
                alert('Please enter a USER_ID for the candidate.');
                e.preventDefault();
                return;
            }

            if (positionId === "") {
                alert('Please select a position.');
                e.preventDefault();
                return;
            }

            if (manifesto.length < 10) {
                alert('Manifesto must be at least 10 characters long.');
                e.preventDefault();
                return;
            }

            if (!confirm('Confirm registering this candidate?')) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>