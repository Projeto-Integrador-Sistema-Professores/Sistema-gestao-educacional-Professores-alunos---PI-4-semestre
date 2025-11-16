package com.sistema.repository;

import com.sistema.model.Material;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MaterialRepository extends MongoRepository<Material, String> {
    List<Material> findBySubject_Id(String subjectId);
    List<Material> findBySubject_IdOrderByUploadedAtDesc(String subjectId);
}

