package com.sistema.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DBRef;

import java.time.LocalDateTime;

@Document(collection = "enrollments")
@Data
@NoArgsConstructor
@AllArgsConstructor
@CompoundIndex(name = "student_subject_idx", def = "{'studentId': 1, 'subjectId': 1}", unique = true)
public class Enrollment {
    @Id
    private String id;
    
    @DBRef
    private User student;
    
    @DBRef
    private Subject subject;
    
    private LocalDateTime enrolledAt;
}

