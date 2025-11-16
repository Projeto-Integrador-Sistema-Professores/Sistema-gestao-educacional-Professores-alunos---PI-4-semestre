package com.sistema.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Document(collection = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    private String id;
    
    private String name;
    
    @Indexed(unique = true)
    private String ra; // Registro Acadêmico
    
    private String role; // "student" | "teacher"
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

