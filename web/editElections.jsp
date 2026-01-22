<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, java.io.*, java.sql.*"%>
<%@page import="util.DBConnection"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Edit Election - iVote</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            body {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                margin: 0;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }

            .edit-election-page {
                width: 100%;
                max-width: 500px;
            }

            .edit-election-container {
                background: white;
                border-radius: 20px;
                padding: 3rem;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            }

            .edit-election-header {
                text-align: center;
                margin-bottom: 2rem;
            }

            .logo-circle {
                font-size: 3rem;
                margin-bottom: 1rem;
                color: #667eea;
            }

            .edit-election-header h1 {
                color: #667eea;
                margin-bottom: 0.5rem;
            }

            .edit-election-header p {
                color: #666;
                font-size: 0.95rem;
            }

            .message {
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 1.5rem;
                text-align: center;
                font-weight: 500;
            }

            .success-message {
                background: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }

            .error-message {
                background: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }

            .form-group {
                margin-bottom: 1.5rem;
            }

            .form-group label {
                display: block;
                margin-bottom: 0.5rem;
                font-weight: 500;
                color: #555;
            }

            .form-group input,
            .form-group select {
                width: 100%;
                padding: 0.9rem;
                border-radius: 10px;
                border: 2px solid #e0e0e0;
                font-size: 1rem;
                transition: all 0.3s ease;
            }

            .form-group input:focus,
            .form-group select:focus {
                outline: none;
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            }

            .btn-group {
                display: flex;
                gap: 1rem;
                margin-top: 2rem;
            }

            .btn {
                flex: 1;
                padding: 0.9rem;
                border: none;
                border-radius: 10px;
                font-size: 1rem;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                text-align: center;
                text-decoration: none;
                display: inline-block;
            }

            .btn-primary {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }

            .btn-secondary {
                background: #6c757d;
                color: white;
            }

            .btn:hover {
                opacity: 0.9;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            }

            .back-link {
                display: inline-block;
                margin-top: 1.5rem;
                color: #667eea;
                text-decoration: none;
                font-weight: 500;
                text-align: center;
                width: 100%;
            }

            .back-link:hover {
                text-decoration: underline;
            }

            .status-option {
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            .status-dot {
                width: 10px;
                height: 10px;
                border-radius: 50%;
                display: inline-block;
            }

            .status-active {
                background-color: #28a745;
            }

            .status-inactive {
                background-color: #dc3545;
            }

            @media (max-width: 576px) {
                .edit-election-container {
                    padding: 2rem;
                }

                .btn-group {
                    flex-direction: column;
                }
            }
        </style>
    </head>
    <body>
        <div class="edit-election-page">
            <div class="edit-election-container">
                <div class="edit-election-header">
                    <div class="logo-circle">🗳</div>
                    <h1>Edit Election</h1>
                    <p>Update election details</p>
                </div>

                <%
                    // Handle form submission FIRST
                    if ("POST".equalsIgnoreCase(request.getMethod())) {
                        if (session == null || session.getAttribute("user_id") == null) {
                            response.sendRedirect("login.jsp");
                            return;
                        }

                        String electionIdStr = request.getParameter("election_id");
                        String electionNamePost = request.getParameter("election_name");
                        String startDatePost = request.getParameter("start_date");
                        String endDatePost = request.getParameter("end_date");
                        String statusPost = request.getParameter("status");

                        Connection conn = null;
                        PreparedStatement stmt = null;

                        if (electionIdStr == null || electionNamePost == null || electionNamePost.trim().isEmpty()
                                || startDatePost == null || startDatePost.isEmpty()
                                || endDatePost == null || endDatePost.isEmpty()
                                || statusPost == null || statusPost.isEmpty()) {
                %>
                <div class="message error-message">
                    Please fill in all fields.
                </div>
                <%
                } else {
                    try {
                        int electionId = Integer.parseInt(electionIdStr);

                        conn = DBConnection.createConnection();
                        String query = "UPDATE ELECTION SET election_name = ?, start_date = ?, "
                                + "end_date = ?, status = ? WHERE election_id = ?";
                        stmt = conn.prepareStatement(query);

                        stmt.setString(1, electionNamePost);
                        stmt.setDate(2, java.sql.Date.valueOf(startDatePost));
                        stmt.setDate(3, java.sql.Date.valueOf(endDatePost));
                        stmt.setString(4, statusPost);
                        stmt.setInt(5, electionId);

                        int rowsUpdated = stmt.executeUpdate();

                        if (rowsUpdated > 0) {
                %>
                <div class="message success-message">
                    Election updated successfully!
                </div>
                <%
                    // Refresh the page to show updated data
                    response.sendRedirect("editElections.jsp?election_id=" + electionId + "&success=true");
                    return;
                } else {
                %>
                <div class="message error-message">
                    Error updating election.
                </div>
                <%
                    }

                } catch (SQLException e) {
                %>
                <div class="message error-message">
                    Error updating election: <%= e.getMessage()%>
                </div>
                <%
                    e.printStackTrace();
                } catch (IllegalArgumentException e) {
                %>
                <div class="message error-message">
                    Invalid date format. Please use YYYY-MM-DD format.
                </div>
                <%
                            } finally {
                                try {
                                    if (stmt != null) {
                                        stmt.close();
                                    }
                                } catch (Exception ex) {
                                }
                                try {
                                    if (conn != null) {
                                        conn.close();
                                    }
                                } catch (Exception ex) {
                                }
                            }
                        }
                    }

                    // Get election_id from parameter (for both GET and POST)
                    String electionIdStr = request.getParameter("election_id");
                    if (electionIdStr == null || electionIdStr.trim().isEmpty()) {
                %>
                <div class="message error-message">
                    Election ID is required.
                </div>
                <a href="adminDashboard.jsp" class="back-link">← Back to Dashboard</a>
                <%
                        return;
                    }

                    int electionId = Integer.parseInt(electionIdStr);

                    Connection conn = null;
                    PreparedStatement stmt = null;
                    ResultSet rs = null;
                    String electionName = "";
                    String startDate = "";
                    String endDate = "";
                    String status = "";

                    try {
                        conn = DBConnection.createConnection();
                        String query = "SELECT * FROM ELECTION WHERE election_id = ?";
                        stmt = conn.prepareStatement(query);
                        stmt.setInt(1, electionId);
                        rs = stmt.executeQuery();

                        if (rs.next()) {
                            electionName = rs.getString("election_name");
                            startDate = rs.getString("start_date");
                            endDate = rs.getString("end_date");
                            status = rs.getString("status");
                        } else {
                %>
                <div class="message error-message">
                    Election not found.
                </div>
                <a href="adminDashboard.jsp" class="back-link">← Back to Dashboard</a>
                <%
                        return;
                    }

                } catch (SQLException e) {
                %>
                <div class="message error-message">
                    Error retrieving election: <%= e.getMessage()%>
                </div>
                <a href="adminDashboard.jsp" class="back-link">← Back to Dashboard</a>
                <%
                        e.printStackTrace();
                        return;
                    } finally {
                        try {
                            if (rs != null) {
                                rs.close();
                            }
                        } catch (Exception ex) {
                        }
                        try {
                            if (stmt != null) {
                                stmt.close();
                            }
                        } catch (Exception ex) {
                        }
                        try {
                            if (conn != null) {
                                conn.close();
                            }
                        } catch (Exception ex) {
                        }
                    }

                    // Check for success parameter
                    if ("true".equals(request.getParameter("success"))) {
                %>
                <div class="message success-message">
                    Election updated successfully!
                </div>
                <%
                    }
                %>

                <form method="POST">
                    <input type="hidden" name="election_id" value="<%= electionId%>">

                    <div class="form-group">
                        <label>Election Name</label>
                        <input type="text" name="election_name" value="<%= electionName%>" required 
                               placeholder="Enter election name">
                    </div>

                    <div class="form-group">
                        <label>Start Date</label>
                        <input type="date" name="start_date" value="<%= startDate%>" required>
                    </div>

                    <div class="form-group">
                        <label>End Date</label>
                        <input type="date" name="end_date" value="<%= endDate%>" required>
                    </div>

                    <div class="form-group">
                        <label>Status</label>
                        <select id="status" name="status" required>
                            <option value="">Select status</option>
                            <option value="ACTIVE" <%= "ACTIVE".equals(status) ? "selected" : ""%>>
                            <span class="status-option">
                                <span class="status-dot status-active"></span>
                                Active
                            </span>
                            </option>
                            <option value="UPCOMING" <%= "UPCOMING".equals(status) ? "selected" : ""%>>
                            <span class="status-option">
                                <span class="status-dot" style="background-color: #ffc107;"></span>
                                Upcoming
                            </span>
                            </option>
                            <option value="CLOSED" <%= "CLOSED".equals(status) ? "selected" : ""%>>
                            <span class="status-option">
                                <span class="status-dot status-inactive"></span>
                                Closed
                            </span>
                            </option>
                        </select>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary">Update Election</button>
                        <a href="adminDashboard.jsp" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>

        <script>
            // Form validation for date range
            document.querySelector('form').addEventListener('submit', function (e) {
                var startDate = document.querySelector('input[name="start_date"]').value;
                var endDate = document.querySelector('input[name="end_date"]').value;

                if (startDate && endDate) {
                    var start = new Date(startDate);
                    var end = new Date(endDate);

                    if (end <= start) {
                        e.preventDefault();
                        alert('End date must be after start date.');
                        return false;
                    }
                }

                // Check if start date is not in the past for active/upcoming elections
                var status = document.querySelector('select[name="status"]').value;
                var today = new Date();
                today.setHours(0, 0, 0, 0);

                if (status === 'ACTIVE' || status === 'UPCOMING') {
                    var start = new Date(startDate);
                    if (start < today) {
                        e.preventDefault();
                        alert('Start date cannot be in the past for active/upcoming elections.');
                        return false;
                    }
                }

                return true;
            });

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
    </body>
</html>