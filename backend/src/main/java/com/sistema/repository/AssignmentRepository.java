package com.sistema.repository;

import com.sistema.model.Assignment;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AssignmentRepository extends MongoRepository<Assignment, String> {
    List<Assignment> findBySubject_Id(String subjectId);
    List<Assignment> findBySubject_IdOrderByCreatedAtDesc(String subjectId);
}

