package com.sistema.controller;

import com.sistema.dto.ApiResponse;
import com.sistema.dto.SubjectDTO;
import com.sistema.model.*;
import com.sistema.repository.*;
import com.sistema.service.AuthService;
import com.sistema.service.GridFSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.util.UUID;

@RestController
@RequestMapping("/api/courses")
public class CourseController {
    
    @Autowired
    private SubjectRepository subjectRepository;
    
    @Autowired
    private AssignmentRepository assignmentRepository;
    
    @Autowired
    private MaterialRepository materialRepository;
    
    @Autowired
    private GradeRepository gradeRepository;
    
    @Autowired
    private EnrollmentRepository enrollmentRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private GridFSService gridFSService;
    
    @Autowired
    private AuthService authService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<SubjectDTO>> getAllCourses(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        
        List<Subject> subjects;
        
        // Se for aluno, mostra apenas matérias em que está matriculado
        User user = authService.validateToken(authHeader).orElse(null);
        if (user != null && authService.isStudent(user)) {
            List<Enrollment> enrollments = enrollmentRepository.findByStudent_Id(user.getId());
            List<String> subjectIds = enrollments.stream()
                    .map(e -> e.getSubject().getId())
                    .collect(Collectors.toList());
            subjects = subjectRepository.findAllById(subjectIds);
        } else {
            // Professores veem todas as matérias
            subjects = subjectRepository.findAll();
        }
        
        List<SubjectDTO> dtos = subjects.stream()
                .map(s -> {
                    SubjectDTO dto = new SubjectDTO();
                    dto.setId(s.getId());
                    dto.setCode(s.getCode());
                    dto.setTitle(s.getName());
                    dto.setDescription(s.getDescription());
                    return dto;
                })
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.of(dtos));
    }
    
    @PostMapping
    public ResponseEntity<Map<String, Object>> createCourse(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestBody Map<String, Object> data) {
        
        // Verifica se é professor
        User user = authService.validateToken(authHeader).orElse(null);
        if (user == null || !authService.isTeacher(user)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Apenas professores podem criar matérias"));
        }
        
        String code = (String) data.get("code");
        String name = (String) data.get("name");
        String description = (String) data.getOrDefault("description", "");
        
        if (code == null || code.isEmpty() || name == null || name.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        
        // Verifica se já existe matéria com esse código
        if (subjectRepository.existsByCode(code)) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("error", "Já existe uma matéria com o código " + code));
        }
        
        Subject subject = new Subject();
        subject.setId(UUID.randomUUID().toString());
        subject.setCode(code);
        subject.setName(name);
        subject.setDescription(description);
        subject.setCreatedAt(LocalDateTime.now());
        subject.setUpdatedAt(LocalDateTime.now());
        
        subject = subjectRepository.save(subject);
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", subject.getId());
        response.put("code", subject.getCode());
        response.put("title", subject.getName());
        response.put("description", subject.getDescription());
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getCourseDetails(@PathVariable String id) {
        Optional<Subject> subjectOpt = subjectRepository.findById(id);
        if (subjectOpt.isEmpty()) {
            // Tenta buscar por código
            subjectOpt = subjectRepository.findByCode(id);
        }
        
        if (subjectOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        Subject subject = subjectOpt.get();
        
        // Busca assignments
        List<Assignment> assignments = assignmentRepository.findBySubject_IdOrderByCreatedAtDesc(subject.getId());
        List<Map<String, Object>> assignmentList = assignments.stream()
                .map(a -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", a.getId());
                    map.put("title", a.getTitle());
                    map.put("description", a.getDescription());
                    map.put("dueDate", a.getDueDate());
                    map.put("weight", a.getWeight());
                    return map;
                })
                .collect(Collectors.toList());
        
        // Busca materials
        List<Material> materials = materialRepository.findBySubject_IdOrderByUploadedAtDesc(subject.getId());
        List<Map<String, Object>> materialList = materials.stream()
                .map(m -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", m.getId());
                    map.put("title", m.getTitle());
                    map.put("fileName", m.getFileName());
                    map.put("fileUrl", m.getFileUrl());
                    return map;
                })
                .collect(Collectors.toList());
        
        // Busca grades
        List<Grade> grades = gradeRepository.findBySubject_Id(subject.getId());
        List<Map<String, Object>> gradeList = grades.stream()
                .map(g -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("studentId", g.getStudent().getId());
                    map.put("studentName", g.getStudent().getName());
                    map.put("assignmentId", g.getAssignment().getId());
                    map.put("score", g.getScore());
                    map.put("finalGrade", g.getScore());
                    return map;
                })
                .collect(Collectors.toList());
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", subject.getId());
        response.put("code", subject.getCode());
        response.put("title", subject.getName());
        response.put("description", subject.getDescription());
        response.put("assignments", assignmentList);
        response.put("materials", materialList);
        response.put("grades", gradeList);
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/{id}/students")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getCourseStudents(@PathVariable String id) {
        Optional<Subject> subjectOpt = subjectRepository.findById(id);
        if (subjectOpt.isEmpty()) {
            subjectOpt = subjectRepository.findByCode(id);
        }
        
        if (subjectOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        Subject subject = subjectOpt.get();
        List<Enrollment> enrollments = enrollmentRepository.findBySubject_Id(subject.getId());
        
        List<Map<String, Object>> students = enrollments.stream()
                .map(e -> {
                    User student = e.getStudent();
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", student.getId());
                    map.put("name", student.getName());
                    map.put("ra", student.getRa());
                    map.put("role", student.getRole());
                    return map;
                })
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(ApiResponse.of(students));
    }
    
    @PostMapping("/{id}/assignments")
    public ResponseEntity<Map<String, Object>> createAssignment(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable String id,
            @RequestBody Map<String, Object> data) {
        
        // Verifica se é professor
        User user = authService.validateToken(authHeader).orElse(null);
        if (user == null || !authService.isTeacher(user)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Apenas professores podem criar atividades"));
        }
        
        Optional<Subject> subjectOpt = subjectRepository.findById(id);
        if (subjectOpt.isEmpty()) {
            subjectOpt = subjectRepository.findByCode(id);
        }
        
        if (subjectOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        Assignment assignment = new Assignment();
        assignment.setId(UUID.randomUUID().toString());
        assignment.setSubject(subjectOpt.get());
        assignment.setTitle((String) data.get("title"));
        assignment.setDescription((String) data.get("description"));
        
        // Parse dueDate
        if (data.get("dueDate") instanceof String) {
            assignment.setDueDate(LocalDateTime.parse((String) data.get("dueDate")));
        }
        
        assignment.setWeight(((Number) data.get("weight")).doubleValue());
        assignment.setCreatedAt(LocalDateTime.now());
        assignment.setUpdatedAt(LocalDateTime.now());
        
        assignment = assignmentRepository.save(assignment);
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", assignment.getId());
        response.put("title", assignment.getTitle());
        response.put("description", assignment.getDescription());
        response.put("dueDate", assignment.getDueDate());
        response.put("weight", assignment.getWeight());
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @PostMapping("/{id}/grades")
    public ResponseEntity<Map<String, Object>> createGrade(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable String id,
            @RequestBody Map<String, Object> data) {
        
        // Verifica se é professor
        User user = authService.validateToken(authHeader).orElse(null);
        if (user == null || !authService.isTeacher(user)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Apenas professores podem lançar notas"));
        }
        
        Optional<Subject> subjectOpt = subjectRepository.findById(id);
        if (subjectOpt.isEmpty()) {
            subjectOpt = subjectRepository.findByCode(id);
        }
        
        if (subjectOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        String studentId = (String) data.get("studentId");
        String assignmentId = (String) data.get("assignmentId");
        Double score = ((Number) data.get("score")).doubleValue();
        
        Optional<User> studentOpt = userRepository.findById(studentId);
        Optional<Assignment> assignmentOpt = assignmentRepository.findById(assignmentId);
        
        if (studentOpt.isEmpty() || assignmentOpt.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        
        // Verifica se já existe nota
        Optional<Grade> existingGrade = gradeRepository.findByAssignment_IdAndStudent_Id(assignmentId, studentId);
        Grade grade;
        
        if (existingGrade.isPresent()) {
            grade = existingGrade.get();
            grade.setScore(score);
            grade.setUpdatedAt(LocalDateTime.now());
        } else {
            grade = new Grade();
            grade.setId(UUID.randomUUID().toString());
            grade.setStudent(studentOpt.get());
            grade.setAssignment(assignmentOpt.get());
            grade.setSubject(subjectOpt.get());
            grade.setScore(score);
            grade.setCreatedAt(LocalDateTime.now());
            grade.setUpdatedAt(LocalDateTime.now());
        }
        
        grade = gradeRepository.save(grade);
        
        Map<String, Object> response = new HashMap<>();
        response.put("ok", true);
        response.put("saved", Map.of(
                "studentId", grade.getStudent().getId(),
                "studentName", grade.getStudent().getName(),
                "assignmentId", grade.getAssignment().getId(),
                "score", grade.getScore()
        ));
        
        return ResponseEntity.ok(response);
    }
    
    @PostMapping(value = "/{id}/materials", consumes = "multipart/form-data")
    public ResponseEntity<Map<String, Object>> uploadMaterial(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable String id,
            @RequestParam("title") String title,
            @RequestParam("file") MultipartFile file) {
        
        // Verifica se é professor
        User user = authService.validateToken(authHeader).orElse(null);
        if (user == null || !authService.isTeacher(user)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Apenas professores podem adicionar materiais"));
        }
        
        Optional<Subject> subjectOpt = subjectRepository.findById(id);
        if (subjectOpt.isEmpty()) {
            subjectOpt = subjectRepository.findByCode(id);
        }
        
        if (subjectOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        try {
            String fileStorageId = gridFSService.uploadFile(file);
            String fileUrl = "/api/materials/" + fileStorageId + "/download";
            
            Material material = new Material();
            material.setId(UUID.randomUUID().toString());
            material.setSubject(subjectOpt.get());
            material.setTitle(title);
            material.setFileName(file.getOriginalFilename());
            material.setFileUrl(fileUrl);
            material.setFileStorageId(fileStorageId);
            material.setUploadedAt(LocalDateTime.now());
            material.setUpdatedAt(LocalDateTime.now());
            
            material = materialRepository.save(material);
            
            Map<String, Object> response = new HashMap<>();
            response.put("ok", true);
            Map<String, Object> materialData = new HashMap<>();
            materialData.put("id", material.getId());
            materialData.put("title", material.getTitle());
            materialData.put("fileName", material.getFileName());
            materialData.put("fileUrl", material.getFileUrl());
            materialData.put("fileStorageId", material.getFileStorageId());
            response.put("material", materialData);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteCourse(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable String id) {
        
        // Verifica se é professor
        User user = authService.validateToken(authHeader).orElse(null);
        if (user == null || !authService.isTeacher(user)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Apenas professores podem deletar matérias"));
        }
        
        Optional<Subject> subjectOpt = subjectRepository.findById(id);
        if (subjectOpt.isEmpty()) {
            subjectOpt = subjectRepository.findByCode(id);
        }
        
        if (subjectOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        Subject subject = subjectOpt.get();
        
        // Deleta enrollments
        enrollmentRepository.deleteBySubject_Id(subject.getId());
        
        // Deleta assignments, materials, grades (cascata manual)
        assignmentRepository.deleteAll(assignmentRepository.findBySubject_Id(subject.getId()));
        materialRepository.deleteAll(materialRepository.findBySubject_Id(subject.getId()));
        gradeRepository.deleteAll(gradeRepository.findBySubject_Id(subject.getId()));
        
        // Deleta subject
        subjectRepository.delete(subject);
        
        Map<String, Object> response = new HashMap<>();
        response.put("ok", true);
        response.put("deleted", id);
        
        return ResponseEntity.ok(response);
    }
}

