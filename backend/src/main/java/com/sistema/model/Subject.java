package com.sistema.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DBRef;

import java.time.LocalDateTime;

@Document(collection = "subjects")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Subject {
    @Id
    private String id;
    
    @Indexed(unique = true)
    private String code; // Ex: "MAT101", "PROG202"
    
    private String name;
    private String description;
    
    @DBRef
    private User teacher; // Professor responsável (opcional)
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

