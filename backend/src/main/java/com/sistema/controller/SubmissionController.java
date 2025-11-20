package com.sistema.controller;

import com.sistema.service.GridFSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/submissions")
public class SubmissionController {
    
    @Autowired
    private GridFSService gridFSService;
    
    @GetMapping("/{fileId}/download")
    public ResponseEntity<byte[]> downloadSubmission(@PathVariable String fileId) {
        try {
            byte[] fileData = gridFSService.downloadFile(fileId);
            return ResponseEntity.ok()
                    .header("Content-Disposition", "attachment; filename=\"submission\"")
                    .body(fileData);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}

