package com.sistema.controller;

import com.sistema.repository.MaterialRepository;
import com.sistema.service.GridFSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/materials")
public class MaterialController {
    
    @Autowired
    private MaterialRepository materialRepository;
    
    @Autowired
    private GridFSService gridFSService;
    
    @GetMapping("/{fileId}/download")
    public ResponseEntity<byte[]> downloadMaterial(@PathVariable String fileId) {
        try {
            byte[] fileData = gridFSService.downloadFile(fileId);
            return ResponseEntity.ok()
                    .header("Content-Disposition", "attachment; filename=\"material\"")
                    .body(fileData);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}

