package com.sistema.repository;

import com.sistema.model.Message;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends MongoRepository<Message, String> {
    List<Message> findByTo_IdOrderBySentAtDesc(String toId);
    List<Message> findByFrom_IdOrderBySentAtDesc(String fromId);
    List<Message> findByIsBroadcastTrueOrderBySentAtDesc();
    List<Message> findAllByOrderBySentAtDesc();
}

