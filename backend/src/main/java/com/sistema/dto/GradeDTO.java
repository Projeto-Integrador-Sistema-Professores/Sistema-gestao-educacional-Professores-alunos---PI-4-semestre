package com.sistema.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GradeDTO {
    private String studentId;
    private String studentName;
    private String assignmentId;
    private Double score;
    private Double finalGrade; // Para compatibilidade com frontend
}

