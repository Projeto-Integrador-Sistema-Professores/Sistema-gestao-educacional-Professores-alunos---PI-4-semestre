package com.sistema.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SubmissionDTO {
    private String id;
    private String assignmentId;
    private String studentId;
    private String studentName;
    private String fileName;
    private String fileUrl;
    private String notes;
    private LocalDateTime submittedAt;
}

