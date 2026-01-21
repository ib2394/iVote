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
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        
        header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            text-align: center;
            border-radius: 10px;
            margin-bottom: 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        header h1 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }
        
        .nav-buttons {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }
        
        .nav-button {
            padding: 12px 24px;
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .nav-button:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }
        
        .candidates-container {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        th {
            padding: 16px;
            text-align: left;
            font-weight: 600;
            font-size: 0.95rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        td {
            padding: 16px;
            border-bottom: 1px solid #e0e0e0;
            vertical-align: middle;
        }
        
        tr:hover {
            background-color: #f8f9fa;
        }
        
        .candidate-photo {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #667eea;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .no-photo {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 14px;
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
        }
        
        .btn-edit, .btn-delete {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }
        
        .btn-edit {
            background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
            color: white;
        }
        
        .btn-edit:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(76, 175, 80, 0.3);
        }
        
        .btn-delete {
            background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%);
            color: white;
        }
        
        .btn-delete:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(244, 67, 54, 0.3);
        }
        
        .no-candidates {
            text-align: center;
            padding: 3rem;
            color: #666;
        }
        
        .no-candidates h3 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            color: #555;
        }
        
        .desc-cell {
            max-width: 300px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .desc-cell:hover {
            white-space: normal;
            overflow: visible;
            position: relative;
            z-index: 1;
            background: white;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            padding: 10px;
            border-radius: 6px;
            max-width: 400px;
        }
        
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-active {
            background-color: #e8f5e9;
            color: #2e7d32;
        }
        
        .status-inactive {
            background-color: #ffebee;
            color: #c62828;
        }
        
        @media (max-width: 1024px) {
            .candidates-container {
                padding: 1rem;
            }
            
            table {
                font-size: 0.9rem;
            }
            
            th, td {
                padding: 12px 8px;
            }
        }
        
        @media (max-width: 768px) {
            .container {
                margin: 1rem auto;
            }
            
            header h1 {
                font-size: 2rem;
            }
            
            .nav-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .nav-button {
                width: 100%;
                max-width: 300px;
                text-align: center;
            }
            
            table {
                display: block;
                overflow-x: auto;
            }
            
            .action-buttons {
                flex-direction: column;
                gap: 4px;
            }
            
            .btn-edit, .btn-delete {
                width: 100%;
                text-align: center;
            }
        }
    </style>
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
        
        // Auto-refresh page every 60 seconds to get updated data
        setTimeout(function() {
            if (confirm('Refresh candidate list to see latest updates?')) {
                location.reload();
            }
        }, 60000);
    </script>
</body>
</html>