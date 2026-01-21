<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, java.io.*, java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Position</title>
    <meta charset="UTF-8">
</head>
<body>

<h1>Add Position</h1>

<%
    // must come with election_id since it redirect from election_id
    String electionIdStr = request.getParameter("election_id");

    if (electionIdStr == null || electionIdStr.trim().isEmpty()) {
        out.println("<p style='color:red;'>Missing election_id. Please choose an election first.</p>");
        out.println("<a href='chooseElection.jsp'>Go choose election</a>");
        return;
    }

    int electionId = Integer.parseInt(electionIdStr);
%>

<form action="addPosition.jsp?election_id=<%= electionId %>" method="POST">
    <table border="0" cellspacing="3" cellpadding="4">
        <tr>
            <td>Position Name</td>
            <td><input type="text" name="position_name" required /></td>
        </tr>
        <tr>
            <td></td>
            <td><input type="submit" value="Add Position" /></td>
        </tr>
    </table>
</form>

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {

    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;

    String positionName = request.getParameter("position_name");

    if (positionName == null || positionName.trim().isEmpty()) {
        out.println("<p style='color:red;'>Position name cannot be empty.</p>");
    } else {
        try {
            conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");

            String query = "INSERT INTO POSITION (position_name, election_id) VALUES (?, ?)";
            stmt = conn.prepareStatement(query);
            stmt.setString(1, positionName);
            stmt.setInt(2, electionId);

            stmt.executeUpdate();

            stmt.close();
            conn.close();

            out.println("<p style='color:green;'>Position added successfully!</p>");

            response.sendRedirect("addPosition.jsp?election_id=" + electionId);
            return;

        } catch (SQLException e) {
            out.println("<p style='color:red;'>Error adding position: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            try { if (stmt != null) stmt.close(); } catch (Exception ex) {}
            try { if (conn != null) conn.close(); } catch (Exception ex) {}
        }
