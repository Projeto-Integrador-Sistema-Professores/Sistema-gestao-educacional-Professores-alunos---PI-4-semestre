package com.sistema.controller;

import com.sistema.model.Material;
import com.sistema.repository.MaterialRepository;
import com.sistema.service.GridFSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Optional;

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
            
            // Tenta encontrar o material pelo fileStorageId para obter o nome do arquivo
            Optional<Material> materialOpt = materialRepository.findByFileStorageId(fileId);
            String fileName = "material";
            String contentType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
            
            if (materialOpt.isPresent()) {
                Material material = materialOpt.get();
                fileName = material.getFileName() != null ? material.getFileName() : "material";
                
                // Determina o content type baseado na extensão do arquivo
                if (fileName.toLowerCase().endsWith(".pdf")) {
                    contentType = MediaType.APPLICATION_PDF_VALUE;
                } else if (fileName.toLowerCase().endsWith(".doc") || fileName.toLowerCase().endsWith(".docx")) {
                    contentType = "application/msword";
                } else if (fileName.toLowerCase().endsWith(".txt")) {
                    contentType = MediaType.TEXT_PLAIN_VALUE;
                } else if (fileName.toLowerCase().endsWith(".jpg") || fileName.toLowerCase().endsWith(".jpeg")) {
                    contentType = MediaType.IMAGE_JPEG_VALUE;
                } else if (fileName.toLowerCase().endsWith(".png")) {
                    contentType = MediaType.IMAGE_PNG_VALUE;
                }
            }
            
            // Codifica o nome do arquivo para o header
            String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8)
                    .replace("+", "%20");
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType(contentType));
            headers.setContentDispositionFormData("attachment", fileName);
            headers.add(HttpHeaders.CONTENT_DISPOSITION, 
                    "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + encodedFileName);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(fileData);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}

