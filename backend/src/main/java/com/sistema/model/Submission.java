package com.sistema.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DBRef;

import java.time.LocalDateTime;

@Document(collection = "submissions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Submission {
    @Id
    private String id;
    
    @DBRef
    private Assignment assignment;
    
    @DBRef
    private User student;
    
    private String fileName;
    private String fileUrl; // URL do arquivo
    private String fileStorageId; // ID no GridFS ou S3
    
    private String notes; // Observações do aluno
    
    private LocalDateTime submittedAt;
    private LocalDateTime updatedAt;
}

