package com.sistema.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DBRef;

import java.time.LocalDateTime;

@Document(collection = "materials")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Material {
    @Id
    private String id;
    
    @DBRef
    private Subject subject;
    
    private String title;
    private String fileName;
    private String fileUrl; // URL do arquivo
    private String fileStorageId; // ID no GridFS ou S3
    
    private LocalDateTime uploadedAt;
    private LocalDateTime updatedAt;
}

