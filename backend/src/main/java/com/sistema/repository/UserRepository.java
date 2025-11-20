package com.sistema.repository;

import com.sistema.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends MongoRepository<User, String> {
    Optional<User> findByRa(String ra);
    boolean existsByRa(String ra);
}

