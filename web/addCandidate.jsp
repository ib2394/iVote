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
</head>
<body>
    <div class="container">
        <header>
            <h1>Add New Candidate</h1>
            <p>Register new candidates for upcoming elections</p>
        </header>
        
        <div class="nav-buttons">
            <a href="adminDashboard.html">← Back to Dashboard</a>
            <a href="viewCandidates.jsp">View Candidate List</a>
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
                        <input type="text" id="candidateName" name="candidateName" required 
                               placeholder="Enter candidate's full name">
                    </div>
                    
                    <div class="form-group">
                        <label for="candidateEmail">Email Address *</label>
                        <input type="email" id="candidateEmail" name="candidateEmail" required 
                               placeholder="Enter email address">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="program">Program/Department *</label>
                        <input type="text" id="program" name="program" required 
                               placeholder="Enter program or department">
                    </div>
                    
                    <div class="form-group">
                        <label for="faculty">Faculty *</label>
                        <select id="faculty" name="faculty" required>
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
                    <textarea id="desc" name="desc" rows="4" required 
                              placeholder="Describe the candidate's campaign platform, achievements, and vision"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="candidatePic">Candidate Photo</label>
                    <input type="file" id="candidatePic" name="candidatePic" 
                           accept="image/*" onchange="previewImage(event)">
                    <small>Accepted formats: JPG, PNG, GIF. Max size: 2MB</small>
                    <div id="imagePreview" style="display: none;">
                        <img id="preview" src="#" alt="Image Preview">
                    </div>
                </div>
                
                <%-- Hidden field for adminID (populated from session) --%>
                <input type="hidden" id="adminID" name="adminID" value="${sessionScope.adminID}">
                
                <button type="submit">
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