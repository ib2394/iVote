<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    Integer user_id = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");

    if (user_id == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get election_id from request param first, then session
    String electionIdParam = request.getParameter("election_id");
    Integer election_id = null;

    if (electionIdParam != null && !electionIdParam.trim().isEmpty()) {
        try {
            election_id = Integer.parseInt(electionIdParam.trim());
            session.setAttribute("election_id", election_id); // save to session
        } catch (NumberFormatException e) {
            // fallback to session or default
            election_id = (Integer) session.getAttribute("election_id");
            if (election_id == null) {
                election_id = 1; // default
                session.setAttribute("election_id", election_id);
            }
        }
    } else {
        // no param, use session
        election_id = (Integer) session.getAttribute("election_id");
        if (election_id == null) {
            election_id = 1;
            session.setAttribute("election_id", election_id);
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Add New Candidate - iVote</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="candidate.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1><i class="fas fa-user-plus"></i> Add New Candidate</h1>
                <p>Register a candidate for an election</p> <!-- Updated text -->
            </div>

            <div class="navigation">
                <a href="adminDashboard.jsp" class="nav-btn">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
                <a href="CandidateListServlet" class="nav-btn">
                    <i class="fas fa-list"></i> View Candidate List
                </a>
            </div>

            <%-- Show feedback messages from the session --%>
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="message success-message">
                    <i class="fas fa-check-circle"></i> ${sessionScope.successMessage}
                </div>
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="message error-message">
                    <i class="fas fa-exclamation-triangle"></i> ${sessionScope.errorMessage}
                </div>
            </c:if>

            <div class="info-card">
                <h3><i class="fas fa-user-shield"></i> Admin Information</h3>
                <div class="user-info-grid">
                    <div class="info-item">
                        <div class="info-label">Admin ID</div>
                        <div class="info-value"><%= user_id%></div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Election ID</div>
                        <div class="info-value"><%= election_id%></div>
                    </div>
                </div>
            </div>

            <form action="AddCandidateServlet" method="post" id="candidateForm">
                <input type="hidden" name="user_id" value="<%= user_id%>">
                <input type="hidden" name="election_id" value="<%= election_id%>">

                <div class="form-group">
                    <label for="candidate_name">Candidate Name <span class="required">*</span></label>
                    <input type="text" id="candidate_name" name="candidate_name" 
                           placeholder="Enter candidate name" required>
                </div>

                <div class="form-group">
                    <label for="faculty">Faculty <span class="required">*</span></label>
                    <input type="text" id="faculty" name="faculty" 
                           placeholder="Enter faculty/department" required>
                </div>

                <div class="form-group">
                    <label for="email">Email <span class="required">*</span></label>
                    <input type="email" id="email" name="email" 
                           placeholder="Enter email address" required>
                </div>

                <div class="form-group">
                    <label for="manifesto">Manifesto <span class="required">*</span></label>
                    <textarea id="manifesto" name="manifesto" 
                              placeholder="Describe the candidate's campaign platform, vision, and promises..."
                              required></textarea>
                </div>

                <button type="submit" class="submit-btn">
                    <i class="fas fa-save"></i> Register as Candidate
                </button>
            </form>

            <script>
                // Auto-hide messages after 5 seconds
                setTimeout(function () {
                    var messages = document.querySelectorAll('.message');
                    messages.forEach(function (msg) {
                        msg.style.transition = 'opacity 0.5s';
                        msg.style.opacity = '0';
                        setTimeout(function () {
                            if (msg.parentNode) {
                                msg.parentNode.removeChild(msg);
                            }
                        }, 500);
                    });
                }, 5000);
            </script>

            <%
                // Clear session messages after displaying
                if (session != null) {
                    session.removeAttribute("successMessage");
                    session.removeAttribute("errorMessage");
                }
            %>
        </div>
    </body>
</html>