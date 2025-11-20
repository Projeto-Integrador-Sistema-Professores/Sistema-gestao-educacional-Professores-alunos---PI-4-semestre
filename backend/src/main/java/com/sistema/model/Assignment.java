package com.sistema.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DBRef;

import java.time.LocalDateTime;

@Document(collection = "assignments")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Assignment {
    @Id
    private String id;
    
    @DBRef
    private Subject subject;
    
    private String title;
    private String description;
    private LocalDateTime dueDate;
    private Double weight;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

