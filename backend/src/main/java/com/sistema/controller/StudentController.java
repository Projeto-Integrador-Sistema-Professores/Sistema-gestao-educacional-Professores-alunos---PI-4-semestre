package com.sistema.controller;

import com.sistema.dto.ApiResponse;
import com.sistema.model.*;
import com.sistema.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.util.UUID;

@RestController
@RequestMapping("/api/students")
public class StudentController {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private EnrollmentRepository enrollmentRepository;
    
    @Autowired
    private SubjectRepository subjectRepository;
    
    @GetMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> getAllStudents() {
        List<User> students = userRepository.findAll().stream()
                .filter(u -> "student".equals(u.getRole()))
                .collect(Collectors.toList());
        
        List<Map<String, Object>> result = students.stream()
                .map(student -> {
                    List<Enrollment> enrollments = enrollmentRepository.findByStudent_Id(student.getId());
                    List<String> subjectIds = enrollments.stream()
                            .map(e -> e.getSubject().getId())
                            .collect(Collectors.toList());
                    
                    List<String> subjectNames = enrollments.stream()
                            .map(e -> e.getSubject().getName())
                            .collect(Collectors.toList());
                    
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", student.getId());
                    map.put("name", student.getName());
                    map.put("ra", student.getRa());
                    map.put("role", student.getRole());
                    map.put("subjects", subjectNames);
                    map.put("subjectIds", subjectIds);
                    return map;
                })
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(ApiResponse.of(result));
    }
    
    @PostMapping
    public ResponseEntity<Map<String, Object>> createStudent(@RequestBody Map<String, Object> data) {
        String ra = (String) data.get("ra");
        
        if (userRepository.existsByRa(ra)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }
        
        User student = new User();
        student.setId(UUID.randomUUID().toString());
        student.setName((String) data.get("name"));
        student.setRa(ra);
        student.setRole("student");
        student.setCreatedAt(LocalDateTime.now());
        student.setUpdatedAt(LocalDateTime.now());
        
        student = userRepository.save(student);
        
        Map<String, Object> response = new HashMap<>();
        response.put("ok", true);
        Map<String, Object> studentData = new HashMap<>();
        studentData.put("id", student.getId());
        studentData.put("name", student.getName());
        studentData.put("ra", student.getRa());
        studentData.put("role", student.getRole());
        response.put("student", studentData);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @PutMapping("/{id}/enrollments")
    public ResponseEntity<Map<String, Object>> updateEnrollments(
            @PathVariable String id,
            @RequestBody Map<String, Object> data) {
        
        Optional<User> studentOpt = userRepository.findById(id);
        if (studentOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        User student = studentOpt.get();
        
        // Remove enrollments existentes
        enrollmentRepository.deleteByStudent_Id(student.getId());
        
        // Cria novos enrollments
        @SuppressWarnings("unchecked")
        List<String> subjectIds = (List<String>) data.get("subjects");
        if (subjectIds != null) {
            for (String subjectId : subjectIds) {
                Optional<Subject> subjectOpt = subjectRepository.findById(subjectId);
                if (subjectOpt.isPresent()) {
                    // Verifica se já existe
                    if (!enrollmentRepository.existsByStudent_IdAndSubject_Id(student.getId(), subjectId)) {
                        Enrollment enrollment = new Enrollment();
                        enrollment.setId(UUID.randomUUID().toString());
                        enrollment.setStudent(student);
                        enrollment.setSubject(subjectOpt.get());
                        enrollment.setEnrolledAt(LocalDateTime.now());
                        enrollmentRepository.save(enrollment);
                    }
                }
            }
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("ok", true);
        response.put("studentId", id);
        response.put("subjects", subjectIds);
        
        return ResponseEntity.ok(response);
    }
}

