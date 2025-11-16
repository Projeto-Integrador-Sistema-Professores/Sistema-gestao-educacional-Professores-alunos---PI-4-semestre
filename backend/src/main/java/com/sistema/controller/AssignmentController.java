package com.sistema.controller;

import com.sistema.dto.ApiResponse;
import com.sistema.model.Assignment;
import com.sistema.model.Submission;
import com.sistema.model.User;
import com.sistema.repository.AssignmentRepository;
import com.sistema.repository.SubmissionRepository;
import com.sistema.repository.UserRepository;
import com.sistema.service.GridFSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.util.UUID;

@RestController
@RequestMapping("/api/assignments")
public class AssignmentController {
    
    @Autowired
    private AssignmentRepository assignmentRepository;
    
    @Autowired
    private SubmissionRepository submissionRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private GridFSService gridFSService;
    
    @GetMapping("/{id}/submissions")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSubmissions(@PathVariable String id) {
        List<Submission> submissions = submissionRepository.findByAssignment_Id(id);
        
        List<Map<String, Object>> result = submissions.stream()
                .map(s -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", s.getId());
                    map.put("assignmentId", s.getAssignment().getId());
                    map.put("studentId", s.getStudent().getId());
                    map.put("studentName", s.getStudent().getName());
                    map.put("fileName", s.getFileName());
                    map.put("fileUrl", s.getFileUrl());
                    map.put("notes", s.getNotes());
                    map.put("submittedAt", s.getSubmittedAt());
                    return map;
                })
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(ApiResponse.of(result));
    }
    
    @PostMapping("/{assignmentId}/submissions")
    public ResponseEntity<Map<String, Object>> submitAssignment(
            @PathVariable String assignmentId,
            @RequestBody Map<String, Object> data) {
        
        String studentId = (String) data.get("studentId");
        String studentName = (String) data.get("studentName");
        String fileName = (String) data.get("fileName");
        String fileUrl = (String) data.get("fileUrl");
        String notes = (String) data.get("notes");
        
        Optional<Assignment> assignmentOpt = assignmentRepository.findById(assignmentId);
        Optional<User> studentOpt = userRepository.findById(studentId);
        
        if (assignmentOpt.isEmpty() || studentOpt.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        
        // Verifica se já existe submissão
        Optional<Submission> existingSubmission = submissionRepository.findByAssignment_IdAndStudent_Id(assignmentId, studentId);
        Submission submission;
        
        if (existingSubmission.isPresent()) {
            submission = existingSubmission.get();
        } else {
            submission = new Submission();
            submission.setId(UUID.randomUUID().toString());
            submission.setAssignment(assignmentOpt.get());
            submission.setStudent(studentOpt.get());
        }
        
        // Se fileUrl contém base64, precisa fazer upload
        if (fileUrl != null && !fileUrl.isEmpty()) {
            // Se for base64, fazer upload para GridFS
            if (fileUrl.startsWith("data:") || fileUrl.length() > 1000) {
                // É base64, precisa fazer upload
                // Por enquanto, salva como URL direta (pode melhorar depois)
                submission.setFileUrl(fileUrl);
            } else {
                submission.setFileUrl(fileUrl);
            }
            submission.setFileName(fileName);
        }
        
        submission.setNotes(notes);
        submission.setSubmittedAt(LocalDateTime.now());
        submission.setUpdatedAt(LocalDateTime.now());
        
        submission = submissionRepository.save(submission);
        
        Map<String, Object> response = new HashMap<>();
        response.put("ok", true);
        Map<String, Object> submissionData = new HashMap<>();
        submissionData.put("id", submission.getId());
        submissionData.put("assignmentId", submission.getAssignment().getId());
        submissionData.put("studentId", submission.getStudent().getId());
        submissionData.put("studentName", submission.getStudent().getName());
        submissionData.put("fileName", submission.getFileName());
        submissionData.put("fileUrl", submission.getFileUrl());
        response.put("submission", submissionData);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}

