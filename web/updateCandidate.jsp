<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.*, java.io.*, java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Update Candidate</title>
        <meta charset="UTF-8">
    </head>
    <body>
        <h1>Update Candidate</h1>
        <form action="updateCandidate.jsp" method="post">
            <%
                String candidate_id = request.getParameter("candidate_id");
                String user_id = request.getParameter("user_id");
                String candidate_name = request.getParameter("candidate_name");
                String email = request.getParameter("email");
                String program = request.getParameter("program");
                String faculty = request.getParameter("faculty");
                String description = request.getParameter("description");
                String photo_url = request.getParameter("photo_url");
                String nomination_date = request.getParameter("nomination_date");

                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    candidate_id = request.getParameter("candidate_id");
                    user_id = request.getParameter("user_id");
                    candidate_name = request.getParameter("candidate_name");
                    email = request.getParameter("email");
                    program = request.getParameter("program");
                    faculty = request.getParameter("faculty");
                    description = request.getParameter("description");
                    photo_url = request.getParameter("photo_url");
                    nomination_date = request.getParameter("nomination_date");
                }
            %>
            <input type="hidden" name="candidate_id" value="<%= candidate_id != null ? candidate_id : ""%>">
            <input type="hidden" name="user_id" value="<%= user_id != null ? user_id : ""%>">
            <table border="0" cellspacing="3" cellpadding="4">
                <tr>
                    <td>Candidate Name</td>
                    <td><input type="text" name="candidate_name" value="<%= candidate_name != null ? candidate_name : ""%>"></td>
                </tr>
                <tr>
                    <td>Email</td>
                    <td><input type="text" name="email" value="<%= email != null ? email : ""%>"></td>
                </tr>
                <tr>
                    <td>Program</td>
                    <td><input type="text" name="program" value="<%= program != null ? program : ""%>"></td>
                </tr>
                <tr>
                    <td>Faculty</td>
                    <td><input type="text" name="faculty" value="<%= faculty != null ? faculty : ""%>"></td>
                </tr>
                <tr>
                    <td>Description</td>
                    <td><input type="text" name="description" value="<%= description != null ? description : ""%>"></td>
                </tr>
                <tr>
                    <td>Picture URL</td>
                    <td><input type="text" name="photo_url" value="<%= photo_url != null ? photo_url : ""%>"></td>
                </tr>
                <tr>
                    <td>Nomination Date</td>
                    <td><input type="text" name="nomination_date" value="<%= nomination_date != null ? nomination_date : ""%>"></td>
                </tr>
                <tr>
                    <td></td>
                    <td><input type="submit" value="Update"></td>
                </tr>
            </table>
        </form>

        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                if (session == null || session.getAttribute("username") == null) {
                    response.sendRedirect("login.jsp");
                    return;
                }

                Connection conn = null;
                PreparedStatement stmt = null;

                try {
                    if (candidate_id == null || candidate_id.trim().isEmpty()
                            || candidate_name == null || candidate_name.trim().isEmpty()
                            || email == null || email.trim().isEmpty()
                            || program == null || program.trim().isEmpty()
                            || faculty == null || faculty.trim().isEmpty()) {
                        out.println("<p style='color:red;'>All fields are required.</p>");
                        return;
                    }

                    conn = DriverManager.getConnection("jdbc:derby://localhost:1527/iVoteDB", "app", "app");
                    
                    String query = "UPDATE CANDIDATES SET CANDIDATE_NAME=?, EMAIL=?, PROGRAM=?, FACULTY=?, DESCRIPTION=?, PHOTO_URL=?, NOMINATION_DATE=? WHERE CANDIDATE_ID=? AND USER_ID=?";
                    
                    stmt = conn.prepareStatement(query);
                    stmt.setString(1, candidate_name.trim());
                    stmt.setString(2, email.trim());
                    stmt.setString(3, program.trim());
                    stmt.setString(4, faculty.trim());
                    stmt.setString(5, description != null ? description.trim() : "");
                    stmt.setString(6, photo_url != null ? photo_url.trim() : "");
                    stmt.setString(7, nomination_date != null ? nomination_date.trim() : "");
                    stmt.setInt(8, Integer.parseInt(candidate_id.trim()));
                    stmt.setInt(9, Integer.parseInt(user_id != null ? user_id.trim() : "0"));

                    int rowsUpdated = stmt.executeUpdate();
                    if (rowsUpdated > 0) {
                        response.sendRedirect("viewCandidates.jsp?message=Candidate updated successfully");
                        return;
                    } else {
                        out.println("<p style='color:red;'>No record found to update.</p>");
                    }
                } catch (NumberFormatException e) {
                    out.println("<p style='color:red;'>Invalid ID format. Please enter valid numbers.</p>");
                } catch (SQLException e) {
                    out.println("<p style='color:red;'>Error updating candidate: " + e.getMessage() + "</p>");
                } finally {
                    if (stmt != null) {
                        try {
                            stmt.close();
                        } catch (SQLException e) {
                        }
                    }
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException e) {
                        }
                    }
                }
            }
        %>

        <p><a href="viewCandidates.jsp">Cancel</a></p>
    </body>
</html>