<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, java.io.*, java.sql.*"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Add Elections</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
        <h1>Add Elections</h1>

        <form action="addElections.jsp" method="POST">
            <table border="0" cellspacing="3" cellpadding="4">

                <tr>
                    <td>Election Name</td>
                    <td><input type="text" name="election_name" value="" required /></td>
                </tr>

                <tr>
                    <td>Start Date</td>
                    <td><input type="date" name="start_date" value="" required /></td>
                </tr>

                <tr>
                    <td>End Date</td>
                    <td><input type="date" name="end_date" value="" required /></td>
                </tr>

                <tr>
                    <td>Status</td>
                    <td>
                        <select id="status" name="status" required>
                            <option value="">Select status</option>
                            <option value="Active">Active</option>
                            <option value="Inactive">Inactive</option>
                        </select>
                    </td>
                </tr>

                <tr>
                    <td></td>
                    <td><input type="submit" value="Add Election" /></td>
                </tr>

            </table>
        </form>

        <%
        if ("POST".equalsIgnoreCase(request.getMethod())) {

            // keep your session check style
            if (session == null || session.getAttribute("user_id") == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            Connection conn = null;
            PreparedStatement stmt = null;

            String election_name = request.getParameter("election_name");
            String start_date = request.getParameter("start_date");
            String end_date = request.getParameter("end_date");
            String status = request.getParameter("status");

            // simple validation (still your style)
            if (election_name == null || election_name.trim().isEmpty()
                || start_date == null || start_date.isEmpty()
                || end_date == null || end_date.isEmpty()
                || status == null || status.isEmpty()) {
                out.println("<p style='color:red;'>Please fill in all fields.</p>");
            } else {
                try {
                    conn = DriverManager.getConnection(
                        "jdbc:derby://localhost:1527/iVoteDB", "app", "app"
                    );

                    // ✅ match your table columns
                    String query = "INSERT INTO ELECTION (election_name, start_date, end_date, status) " +
                                   "VALUES (?, ?, ?, ?)";
                    stmt = conn.prepareStatement(query);

                    stmt.setString(1, election_name);

                    // ✅ start_date and end_date are DATE in DB
                    stmt.setDate(2, java.sql.Date.valueOf(start_date));
                    stmt.setDate(3, java.sql.Date.valueOf(end_date));

                    stmt.setString(4, status);

                    stmt.executeUpdate();

                    // close
                    stmt.close();
                    conn.close();

                    out.println("<p style='color:green;'>Election added successfully!</p>");

                    // optional: redirect to clear form resubmission (you had redirect, keep it)
                    response.sendRedirect("addElections.jsp");
                    return;

                } catch (SQLException e) {
                    out.println("<p style='color:red;'>Error adding election: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                } catch (IllegalArgumentException e) {
                    out.println("<p style='color:red;'>Invalid date format.</p>");
                } finally {
                    try { if (stmt != null) stmt.close(); } catch (Exception ex) {}
                    try { if (conn != null) conn.close(); } catch (Exception ex) {}
                }
            }
        }
        %>

    </body>
</html>