package com.sistema.service;

import com.sistema.model.*;
import com.sistema.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.UUID;

@Service
public class MigrationService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private SubjectRepository subjectRepository;
    
    @Autowired
    private EnrollmentRepository enrollmentRepository;
    
    @Autowired
    private AssignmentRepository assignmentRepository;
    
    @Autowired
    private SubmissionRepository submissionRepository;
    
    @Autowired
    private GradeRepository gradeRepository;
    
    @Autowired
    private MaterialRepository materialRepository;
    
    @Autowired
    private MessageRepository messageRepository;
    
    public void migrateFromJson(Map<String, Object> data) {
        // Migra Users
        if (data.containsKey("users")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> users = (List<Map<String, Object>>) data.get("users");
            for (Map<String, Object> userData : users) {
                migrateUser(userData);
            }
        }
        
        // Migra Subjects
        if (data.containsKey("subjects")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> subjects = (List<Map<String, Object>>) data.get("subjects");
            for (Map<String, Object> subjectData : subjects) {
                migrateSubject(subjectData);
            }
        }
        
        // Migra Enrollments
        if (data.containsKey("enrollments")) {
            @SuppressWarnings("unchecked")
            Map<String, List<String>> enrollments = (Map<String, List<String>>) data.get("enrollments");
            for (Map.Entry<String, List<String>> entry : enrollments.entrySet()) {
                migrateEnrollments(entry.getKey(), entry.getValue());
            }
        }
        
        // Migra Assignments e Grades (por course)
        if (data.containsKey("courses")) {
            @SuppressWarnings("unchecked")
            Map<String, Map<String, Object>> courses = (Map<String, Map<String, Object>>) data.get("courses");
            for (Map.Entry<String, Map<String, Object>> entry : courses.entrySet()) {
                migrateCourseData(entry.getKey(), entry.getValue());
            }
        }
        
        // Migra Materials
        if (data.containsKey("materials")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> materials = (List<Map<String, Object>>) data.get("materials");
            for (Map<String, Object> materialData : materials) {
                migrateMaterial(materialData);
            }
        }
        
        // Migra Submissions
        if (data.containsKey("submissions")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> submissions = (List<Map<String, Object>>) data.get("submissions");
            for (Map<String, Object> submissionData : submissions) {
                migrateSubmission(submissionData);
            }
        }
        
        // Migra Messages
        if (data.containsKey("messages")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> messages = (List<Map<String, Object>>) data.get("messages");
            for (Map<String, Object> messageData : messages) {
                migrateMessage(messageData);
            }
        }
    }
    
    private void migrateUser(Map<String, Object> userData) {
        String ra = (String) userData.get("ra");
        if (ra != null && !userRepository.existsByRa(ra)) {
            User user = new User();
            user.setId((String) userData.getOrDefault("id", UUID.randomUUID().toString()));
            user.setName((String) userData.get("name"));
            user.setRa(ra);
            user.setRole((String) userData.getOrDefault("role", "student"));
            user.setCreatedAt(parseDateTime(userData.get("createdAt")));
            user.setUpdatedAt(LocalDateTime.now());
            userRepository.save(user);
        }
    }
    
    private void migrateSubject(Map<String, Object> subjectData) {
        String code = (String) subjectData.get("code");
        if (code != null && !subjectRepository.existsByCode(code)) {
            Subject subject = new Subject();
            subject.setId((String) subjectData.getOrDefault("id", UUID.randomUUID().toString()));
            subject.setCode(code);
            subject.setName((String) subjectData.get("name"));
            subject.setDescription((String) subjectData.get("description"));
            subject.setCreatedAt(parseDateTime(subjectData.get("createdAt")));
            subject.setUpdatedAt(LocalDateTime.now());
            subjectRepository.save(subject);
        }
    }
    
    private void migrateEnrollments(String studentId, List<String> subjectIds) {
        Optional<User> studentOpt = userRepository.findById(studentId);
        if (studentOpt.isEmpty()) return;
        
        for (String subjectId : subjectIds) {
            Optional<Subject> subjectOpt = subjectRepository.findById(subjectId);
            if (subjectOpt.isPresent() && 
                !enrollmentRepository.existsByStudent_IdAndSubject_Id(studentId, subjectId)) {
                Enrollment enrollment = new Enrollment();
                enrollment.setId(UUID.randomUUID().toString());
                enrollment.setStudent(studentOpt.get());
                enrollment.setSubject(subjectOpt.get());
                enrollment.setEnrolledAt(LocalDateTime.now());
                enrollmentRepository.save(enrollment);
            }
        }
    }
    
    private void migrateCourseData(String courseId, Map<String, Object> courseData) {
        Optional<Subject> subjectOpt = subjectRepository.findById(courseId);
        if (subjectOpt.isEmpty()) {
            subjectOpt = subjectRepository.findByCode(courseId);
        }
        if (subjectOpt.isEmpty()) return;
        
        Subject subject = subjectOpt.get();
        
        // Migra Assignments
        if (courseData.containsKey("assignments")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> assignments = (List<Map<String, Object>>) courseData.get("assignments");
            for (Map<String, Object> assignmentData : assignments) {
                migrateAssignment(subject, assignmentData);
            }
        }
        
        // Migra Grades
        if (courseData.containsKey("grades")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> grades = (List<Map<String, Object>>) courseData.get("grades");
            for (Map<String, Object> gradeData : grades) {
                migrateGrade(subject, gradeData);
            }
        }
    }
    
    private void migrateAssignment(Subject subject, Map<String, Object> assignmentData) {
        String assignmentId = (String) assignmentData.getOrDefault("id", UUID.randomUUID().toString());
        if (assignmentRepository.findById(assignmentId).isEmpty()) {
            Assignment assignment = new Assignment();
            assignment.setId(assignmentId);
            assignment.setSubject(subject);
            assignment.setTitle((String) assignmentData.get("title"));
            assignment.setDescription((String) assignmentData.get("description"));
            assignment.setDueDate(parseDateTime(assignmentData.get("dueDate")));
            assignment.setWeight(((Number) assignmentData.getOrDefault("weight", 1.0)).doubleValue());
            assignment.setCreatedAt(parseDateTime(assignmentData.get("createdAt")));
            assignment.setUpdatedAt(LocalDateTime.now());
            assignmentRepository.save(assignment);
        }
    }
    
    private void migrateGrade(Subject subject, Map<String, Object> gradeData) {
        String studentId = (String) gradeData.get("studentId");
        String assignmentId = (String) gradeData.get("assignmentId");
        
        Optional<User> studentOpt = userRepository.findById(studentId);
        Optional<Assignment> assignmentOpt = assignmentRepository.findById(assignmentId);
        
        if (studentOpt.isPresent() && assignmentOpt.isPresent() &&
            gradeRepository.findByAssignment_IdAndStudent_Id(assignmentId, studentId).isEmpty()) {
            Grade grade = new Grade();
            grade.setId(UUID.randomUUID().toString());
            grade.setStudent(studentOpt.get());
            grade.setAssignment(assignmentOpt.get());
            grade.setSubject(subject);
            grade.setScore(((Number) gradeData.getOrDefault("score", gradeData.get("finalGrade"))).doubleValue());
            grade.setCreatedAt(parseDateTime(gradeData.get("createdAt")));
            grade.setUpdatedAt(LocalDateTime.now());
            gradeRepository.save(grade);
        }
    }
    
    private void migrateMaterial(Map<String, Object> materialData) {
        String courseId = (String) materialData.get("courseId");
        Optional<Subject> subjectOpt = subjectRepository.findById(courseId);
        if (subjectOpt.isEmpty()) {
            subjectOpt = subjectRepository.findByCode(courseId);
        }
        if (subjectOpt.isEmpty()) return;
        
        Material material = new Material();
        material.setId((String) materialData.getOrDefault("id", UUID.randomUUID().toString()));
        material.setSubject(subjectOpt.get());
        material.setTitle((String) materialData.get("title"));
        material.setFileName((String) materialData.get("fileName"));
        material.setFileUrl((String) materialData.get("fileUrl"));
        material.setUploadedAt(parseDateTime(materialData.get("uploadedAt")));
        material.setUpdatedAt(LocalDateTime.now());
        materialRepository.save(material);
    }
    
    private void migrateSubmission(Map<String, Object> submissionData) {
        String assignmentId = (String) submissionData.get("assignmentId");
        String studentId = (String) submissionData.get("studentId");
        
        Optional<Assignment> assignmentOpt = assignmentRepository.findById(assignmentId);
        Optional<User> studentOpt = userRepository.findById(studentId);
        
        if (assignmentOpt.isPresent() && studentOpt.isPresent() &&
            submissionRepository.findByAssignment_IdAndStudent_Id(assignmentId, studentId).isEmpty()) {
            Submission submission = new Submission();
            submission.setId((String) submissionData.getOrDefault("id", UUID.randomUUID().toString()));
            submission.setAssignment(assignmentOpt.get());
            submission.setStudent(studentOpt.get());
            submission.setFileName((String) submissionData.get("fileName"));
            submission.setFileUrl((String) submissionData.get("fileUrl"));
            submission.setNotes((String) submissionData.get("notes"));
            submission.setSubmittedAt(parseDateTime(submissionData.get("submittedAt")));
            submission.setUpdatedAt(LocalDateTime.now());
            submissionRepository.save(submission);
        }
    }
    
    private void migrateMessage(Map<String, Object> messageData) {
        String fromId = (String) messageData.get("fromId");
        String toId = (String) messageData.get("toId");
        
        Optional<User> fromOpt = userRepository.findById(fromId);
        if (fromOpt.isEmpty()) return;
        
        Message message = new Message();
        message.setId((String) messageData.getOrDefault("id", UUID.randomUUID().toString()));
        message.setFrom(fromOpt.get());
        
        if (toId != null && !toId.isEmpty()) {
            Optional<User> toOpt = userRepository.findById(toId);
            toOpt.ifPresent(message::setTo);
        }
        
        message.setContent((String) messageData.get("content"));
        message.setIsBroadcast((Boolean) messageData.getOrDefault("isBroadcast", false));
        message.setSentAt(parseDateTime(messageData.get("sentAt")));
        messageRepository.save(message);
    }
    
    private LocalDateTime parseDateTime(Object dateObj) {
        if (dateObj == null) {
            return LocalDateTime.now();
        }
        if (dateObj instanceof LocalDateTime) {
            return (LocalDateTime) dateObj;
        }
        if (dateObj instanceof String) {
            try {
                return LocalDateTime.parse((String) dateObj);
            } catch (Exception e) {
                return LocalDateTime.now();
            }
        }
        return LocalDateTime.now();
    }
}

