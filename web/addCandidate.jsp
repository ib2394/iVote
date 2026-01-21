<%-- 
    Document   : addCandidate
    Created on : 20 Jan, 2026, 8:35:16 PM
    Author     : USER
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add New Candidate - iVote</title>
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
            max-width: 900px;
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
        
        .form-container {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #555;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .submit-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 14px 28px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            width: 100%;
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }
        
        .message {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            text-align: center;
            font-weight: 600;
        }
        
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }
        
        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .container {
                margin: 1rem auto;
            }
            
            header h1 {
                font-size: 2rem;
            }
            
            .nav-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Add New Candidate</h1>
            <p>Register new candidates for upcoming elections</p>
        </header>
        
        <div class="nav-buttons">
            <a href="adminDashboard.html" class="nav-button">← Back to Dashboard</a>
            <a href="viewCandidates.jsp" class="nav-button">View Candidate List</a>
        </div>
        
        <div class="form-container">
            <%-- Display success/error messages --%>
            <c:if test="${not empty message}">
                <div class="message ${messageType}">
                    ${message}
                </div>
            </c:if>
            
            <form action="AddCandidateServlet" method="post" id="candidateForm" enctype="multipart/form-data">
                <div class="form-row">
                    <div class="form-group">
                        <label for="candidateName">Candidate Name *</label>
                        <input type="text" id="candidateName" name="candidateName" class="form-control" required 
                               placeholder="Enter candidate's full name">
                    </div>
                    
                    <div class="form-group">
                        <label for="candidateEmail">Email Address *</label>
                        <input type="email" id="candidateEmail" name="candidateEmail" class="form-control" required 
                               placeholder="Enter email address">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="program">Program/Department *</label>
                        <input type="text" id="program" name="program" class="form-control" required 
                               placeholder="Enter program or department">
                    </div>
                    
                    <div class="form-group">
                        <label for="faculty">Faculty *</label>
                        <select id="faculty" name="faculty" class="form-control" required>
                            <option value="">Select Faculty</option>
                            <option value="Science">Faculty of Science</option>
                            <option value="Engineering">Faculty of Engineering</option>
                            <option value="Arts">Faculty of Arts</option>
                            <option value="Business">Faculty of Business</option>
                            <option value="Medicine">Faculty of Medicine</option>
                            <option value="Law">Faculty of Law</option>
                            <option value="Education">Faculty of Education</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="desc">Description/Platform *</label>
                    <textarea id="desc" name="desc" class="form-control" rows="4" required 
                              placeholder="Describe the candidate's campaign platform, achievements, and vision"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="candidatePic">Candidate Photo</label>
                    <input type="file" id="candidatePic" name="candidatePic" class="form-control" 
                           accept="image/*" onchange="previewImage(event)">
                    <small>Accepted formats: JPG, PNG, GIF. Max size: 2MB</small>
                    <div id="imagePreview" style="margin-top: 10px; display: none;">
                        <img id="preview" src="#" alt="Image Preview" style="max-width: 200px; max-height: 200px; border-radius: 5px;">
                    </div>
                </div>
                
                <%-- Hidden field for adminID (populated from session) --%>
                <input type="hidden" id="adminID" name="adminID" value="${sessionScope.adminID}">
                
                <button type="submit" class="submit-btn">
                    Register Candidate
                </button>
            </form>
        </div>
    </div>
    
    <script>
        // Image preview function
        function previewImage(event) {
            const reader = new FileReader();
            const preview = document.getElementById('preview');
            const previewContainer = document.getElementById('imagePreview');
            
            reader.onload = function() {
                preview.src = reader.result;
                previewContainer.style.display = 'block';
            }
            
            if (event.target.files[0]) {
                reader.readAsDataURL(event.target.files[0]);
            }
        }
        
        // Form validation
        document.getElementById('candidateForm').addEventListener('submit', function(e) {
            const candidateName = document.getElementById('candidateName').value.trim();
            const email = document.getElementById('candidateEmail').value.trim();
            const desc = document.getElementById('desc').value.trim();
            
            // Validate name
            if (candidateName.length < 2) {
                alert('Candidate name must be at least 2 characters long');
                e.preventDefault();
                return;
            }
            
            // Validate email format
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert('Please enter a valid email address');
                e.preventDefault();
                return;
            }
            
            // Validate description length
            if (desc.length < 20) {
                alert('Description/Platform must be at least 20 characters long');
                e.preventDefault();
                return;
            }
            
            // File size validation (if file is selected)
            const fileInput = document.getElementById('candidatePic');
            if (fileInput.files[0]) {
                const fileSize = fileInput.files[0].size; // in bytes
                const maxSize = 2 * 1024 * 1024; // 2MB
                
                if (fileSize > maxSize) {
                    alert('Image file size must be less than 2MB');
                    e.preventDefault();
                    return;
                }
            }
            
            // Confirm submission
            if (!confirm('Are you sure you want to register this candidate?')) {
                e.preventDefault();
            }
        });
        
        // Auto-hide messages after 5 seconds
        setTimeout(function() {
            const messages = document.querySelectorAll('.message');
            messages.forEach(function(message) {
                message.style.display = 'none';
            });
        }, 5000);
    </script>
</body>
</html>
