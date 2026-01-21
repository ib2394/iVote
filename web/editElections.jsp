<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, java.io.*, java.sql.*"%>
<%@page import="util.DBConnection"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Edit Election</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
        <h1>Edit Election</h1>

        <%
            String electionIdStr = request.getParameter("election_id");
            if (electionIdStr == null || electionIdStr.trim().isEmpty()) {
                out.println("<p style='color:red;'>Election ID is required.</p>");
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
                // Using DBConnection utility to create a connection
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
                    out.println("<p style='color:red;'>Election not found.</p>");
                    return;
                }

            } catch (SQLException e) {
                out.println("<p style='color:red;'>Error retrieving election: " + e.getMessage() + "</p>");
                e.printStackTrace();
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception ex) {}
                try { if (stmt != null) stmt.close(); } catch (Exception ex) {}
                try { if (conn != null) conn.close(); } catch (Exception ex) {}
            }
        %>

        <form action="editElections.jsp?election_id=<%= electionId %>" method="POST">
            <table border="0" cellspacing="3" cellpadding="4">
                <tr>
                    <td>Election Name</td>
                    <td><input type="text" name="election_name" value="<%= electionName %>" required /></td>
                </tr>

                <tr>
                    <td>Start Date</td>
                    <td><input type="date" name="start_date" value="<%= startDate %>" required /></td>
                </tr>

                <tr>
                    <td>End Date</td>
                    <td><input type="date" name="end_date" value="<%= endDate %>" required /></td>
                </tr>

                <tr>
                    <td>Status</td>
                    <td>
                        <select id="status" name="status" required>
                            <option value="">Select status</option>
                            <option value="Active" <%= "Active".equals(status) ? "selected" : "" %>>Active</option>
                            <option value="Inactive" <%= "Inactive".equals(status) ? "selected" : "" %>>Inactive</option>
                        </select>
                    </td>
                </tr>

                <tr>
                    <td></td>
                    <td><input type="submit" value="Update Election" /></td>
                </tr>
            </table>
        </form>

        <%
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            if (session == null || session.getAttribute("user_id") == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String electionNamePost = request.getParameter("election_name");
            String startDatePost = request.getParameter("start_date");
            String endDatePost = request.getParameter("end_date");
            String statusPost = request.getParameter("status");

            // Simple validation
            if (electionNamePost == null || electionNamePost.trim().isEmpty()
                || startDatePost == null || startDatePost.isEmpty()
                || endDatePost == null || endDatePost.isEmpty()
                || statusPost == null || statusPost.isEmpty()) {
                out.println("<p style='color:red;'>Please fill in all fields.</p>");
            } else {
                try {
                    // Using DBConnection utility to create a connection
                    conn = DBConnection.createConnection();

                    // Update query
                    String query = "UPDATE ELECTION SET election_name = ?, start_date = ?, end_date = ?, status = ? WHERE election_id = ?";
                    stmt = conn.prepareStatement(query);

                    stmt.setString(1, electionNamePost);
                    stmt.setDate(2, java.sql.Date.valueOf(startDatePost));
                    stmt.setDate(3, java.sql.Date.valueOf(endDatePost));
                    stmt.setString(4, statusPost);
                    stmt.setInt(5, electionId);

                    int rowsUpdated = stmt.executeUpdate();

                    if (rowsUpdated > 0) {
                        out.println("<p style='color:green;'>Election updated successfully!</p>");
                    } else {
                        out.println("<p style='color:red;'>Error updating election.</p>");
                    }

                    stmt.close();
                    conn.close();

                    // Optional: redirect after successful update to prevent form resubmission
                    response.sendRedirect("editElections.jsp?election_id=" + electionId);
                    return;

                } catch (SQLException e) {
                    out.println("<p style='color:red;'>Error updating election: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                } finally {
                    try { if (stmt != null) stmt.close(); } catch (Exception ex) {}
                    try { if (conn != null) conn.close(); } catch (Exception ex) {}
                }
            }
        }
        %>

    </body>
</html>
