package com.sistema.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DBRef;

import java.time.LocalDateTime;

@Document(collection = "grades")
@Data
@NoArgsConstructor
@AllArgsConstructor
@CompoundIndex(name = "assignment_student_idx", def = "{'assignmentId': 1, 'studentId': 1}", unique = true)
public class Grade {
    @Id
    private String id;
    
    @DBRef
    private User student;
    
    @DBRef
    private Assignment assignment;
    
    @DBRef
    private Subject subject; // Para queries rápidas (denormalização)
    
    private Double score;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

