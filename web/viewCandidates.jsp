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
    <h1>Candidate List</h1>
    <p>Showing candidates with linked user details</p>
    
    <div>
        <a href="adminDashboard.jsp">Back to Dashboard</a>
        <a href="addCandidate.jsp">Add New Candidate</a>
    </div>
    
    <div>
        <c:choose>
            <c:when test="${not empty candidates}">
                <table border="1" cellpadding="8" cellspacing="0" style="width:100%; border-collapse: collapse;">
                    <thead>
                        <tr>
                            <th>Candidate ID</th>
                            <th>User ID</th>
                            <th>User Name</th>
                            <th>Email</th>
                            <th>Election</th>
                            <th>Manifesto</th>
                            <th style="text-align:right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${candidates}" var="c">
                            <tr>
                                <td>${c.candidateId}</td>
                                <td>${c.userId}</td>
                                <td>${c.userName}</td>
                                <td>${c.email}</td>
                                <td><c:out value="${empty c.electionName ? '—' : c.electionName}"/></td>
                                <td>${empty c.manifesto ? 'N/A' : c.manifesto}</td>
                                <td style="text-align:right; white-space:nowrap;">
                                    <button type="button"
                                            data-candidate-id="${c.candidateId}"
                                            onclick="editCandidate(this)">Edit</button>
                                    <button type="button"
                                            data-candidate-id="${c.candidateId}"
                                            data-candidate-name="${c.userName}"
                                            onclick="deleteCandidate(this)">Delete</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div>
                    <h3>No Candidates Found</h3>
                    <p>No candidates have been registered yet. Start by adding the first candidate.</p>
                    <a href="addCandidate.jsp">Add First Candidate</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script>
        function editCandidate(buttonEl) {
            var candidateId = buttonEl.getAttribute('data-candidate-id');
            if (confirm('Edit candidate with ID: ' + candidateId + '?')) {
                window.location.href = 'updateCandidate.jsp?candidateId=' + candidateId;
            }
        }

        function deleteCandidate(buttonEl) {
            var candidateId = buttonEl.getAttribute('data-candidate-id');
            var candidateName = buttonEl.getAttribute('data-candidate-name') || '';
            if (confirm('Are you sure you want to delete candidate: ' + candidateName + ' ? This action cannot be undone.')) {
                window.location.href = 'DeleteCandidateServlet?candidateId=' + candidateId;
            }
        }
    </script>
</body>
</html>