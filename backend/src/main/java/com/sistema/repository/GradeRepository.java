package com.sistema.repository;

import com.sistema.model.Grade;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GradeRepository extends MongoRepository<Grade, String> {
    List<Grade> findByAssignment_Id(String assignmentId);
    List<Grade> findBySubject_Id(String subjectId);
    List<Grade> findByStudent_Id(String studentId);
    List<Grade> findBySubject_IdAndStudent_Id(String subjectId, String studentId);
    Optional<Grade> findByAssignment_IdAndStudent_Id(String assignmentId, String studentId);
}

