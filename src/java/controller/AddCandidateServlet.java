/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import bean.Candidate;
import dao.CandidateDAO;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/AddCandidateServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AddCandidateServlet extends HttpServlet {
    
    private static final String UPLOAD_DIR = "candidate_images";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check if admin is logged in
        String adminID = (String) session.getAttribute("adminID");
        if (adminID == null) {
            response.sendRedirect("adminLogin.jsp");
            return;
        }
        
        // Get form parameters
        String candidateName = request.getParameter("candidateName");
        String candidateEmail = request.getParameter("candidateEmail");
        String program = request.getParameter("program");
        String faculty = request.getParameter("faculty");
        String desc = request.getParameter("desc");
        
        // Handle file upload for candidate picture
        String candidatePic = null;
        Part filePart = request.getPart("candidatePic");
        
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
                
                candidatePic = UPLOAD_DIR + "/" + uniqueFileName;
            }
        }
        
        // Validate required fields
        if (candidateName == null || candidateName.trim().isEmpty() ||
            candidateEmail == null || candidateEmail.trim().isEmpty() ||
            faculty == null || faculty.trim().isEmpty() ||
            desc == null || desc.trim().isEmpty()) {
            
            session.setAttribute("errorMessage", "Please fill in all required fields!");
            response.sendRedirect("addCandidate.jsp");
            return;
        }
        
        // Validate email format
        if (!candidateEmail.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            session.setAttribute("errorMessage", "Please enter a valid email address!");
            response.sendRedirect("addCandidate.jsp");
            return;
        }
        
        // Create Candidate object
        Candidate candidate = new Candidate();
        candidate.setCandidateName(candidateName.trim());
        candidate.setCandidateEmail(candidateEmail.trim());
        candidate.setCandidatePic(candidatePic);
        candidate.setProgram(program != null ? program.trim() : "");
        candidate.setFaculty(faculty.trim());
        candidate.setDesc(desc.trim());
        candidate.setAdminID(adminID);
        
        // Create CandidateDao object
        CandidateDAO candidateDAO = new CandidateDAO();
        
        // Call addCandidate method
        boolean result = candidateDAO.addCandidate(candidate);
        
        // Dispatch based on result
        if ("SUCCESS".equals(result)) {
            session.setAttribute("successMessage", "Candidate '" + candidateName + "' added successfully!");
            
            // Option 1: Redirect to admin dashboard
            response.sendRedirect("adminDashboard.jsp");
            
            // Option 2: If you want to stay on addCandidate.jsp with success message
            // RequestDispatcher dispatcher = request.getRequestDispatcher("addCandidate.jsp");
            // dispatcher.forward(request, response);
            
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
        // Redirect GET requests to addCandidate.jsp
        response.sendRedirect("addCandidate.jsp");
    }
}