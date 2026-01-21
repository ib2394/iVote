/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import bean.*;
import dao.*;
import java.io.*;
import java.nio.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AddCandidateServlet extends HttpServlet {
    
    private static final String UPLOAD_DIR = "photoUrl";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check if admin is logged in
        String adminID = (String) session.getAttribute("adminID");
        if (adminID == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get form parameters
        String candidateName = request.getParameter("candidateName");
        String email = request.getParameter("email");
        String program = request.getParameter("program");
        String faculty = request.getParameter("faculty");
        String description = request.getParameter("description");
        
        // Handle file upload for candidate picture
        String photoUrl = null;
        Part filePart = request.getPart("photoUrl");
        
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = getFileName(filePart);
            if (fileName != null && !fileName.isEmpty()) {
                // Get application path
                String appPath = request.getServletContext().getRealPath("");
                String uploadPath = appPath + File.separator + UPLOAD_DIR;
                
                // Create directory if not exists
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                
                // Generate unique filename
                String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                File file = new File(uploadDir, uniqueFileName);
                
                // Save file
                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
                
                photoUrl = UPLOAD_DIR + "/" + uniqueFileName;
            }
        }
        
        // Validate required fields
        if (candidateName == null || candidateName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            faculty == null || faculty.trim().isEmpty() ||
            description == null || description.trim().isEmpty()) {
            
            session.setAttribute("errorMessage", "Please fill in all required fields!");
            response.sendRedirect("addCandidate.jsp");
            return;
        }
        
        // Validate email format
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            session.setAttribute("errorMessage", "Please enter a valid email address!");
            response.sendRedirect("addCandidate.jsp");
            return;
        }
        
        // Create Candidate object
        Candidate candidate = new Candidate();
        candidate.setCandidateName(candidateName.trim());
        candidate.setEmail(email.trim());
        candidate.setPhotoUrl(photoUrl);
        candidate.setProgram(program != null ? program.trim() : "");
        candidate.setFaculty(faculty.trim());
        candidate.setDescription(description.trim());
        //candidate.setAdminID(adminID);
        
        // Create CandidateDao object
        CandidateDAO candidateDAO = new CandidateDAO();
        
        // Call addCandidate method
        boolean result = candidateDAO.addCandidate(candidate);
        
        // Dispatch based on result
        if ("SUCCESS".equals(result)) {
            session.setAttribute("successMessage", "Candidate '" + candidateName + "' added successfully!");
            
            response.sendRedirect("adminDashboard.jsp");
            ;
            
        } else {
            session.setAttribute("errorMessage", "Failed to add candidate. " + result);
            response.sendRedirect("addCandidate.jsp");
        }
    }
    
    // Helper method to get filename from part
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                return item.substring(item.indexOf("=") + 2, item.length() - 1);
            }
        }
        return null;
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("addCandidate.jsp");
    }
}