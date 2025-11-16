package com.sistema.repository;

import com.sistema.model.Enrollment;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EnrollmentRepository extends MongoRepository<Enrollment, String> {
    List<Enrollment> findByStudent_Id(String studentId);
    List<Enrollment> findBySubject_Id(String subjectId);
    Optional<Enrollment> findByStudent_IdAndSubject_Id(String studentId, String subjectId);
    boolean existsByStudent_IdAndSubject_Id(String studentId, String subjectId);
    void deleteByStudent_Id(String studentId);
    void deleteBySubject_Id(String subjectId);
}

