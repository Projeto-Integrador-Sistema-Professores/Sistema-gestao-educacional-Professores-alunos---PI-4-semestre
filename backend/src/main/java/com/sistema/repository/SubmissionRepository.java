package com.sistema.repository;

import com.sistema.model.Submission;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SubmissionRepository extends MongoRepository<Submission, String> {
    List<Submission> findByAssignment_Id(String assignmentId);
    List<Submission> findByStudent_Id(String studentId);
    Optional<Submission> findByAssignment_IdAndStudent_Id(String assignmentId, String studentId);
}

