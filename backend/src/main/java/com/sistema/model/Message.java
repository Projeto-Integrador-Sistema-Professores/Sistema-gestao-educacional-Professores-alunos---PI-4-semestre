package com.sistema.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DBRef;

import java.time.LocalDateTime;

@Document(collection = "messages")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Message {
    @Id
    private String id;
    
    @DBRef
    private User from; // Professor que enviou
    
    @DBRef
    private User to; // Aluno que recebeu (null = broadcast)
    
    private String content;
    private Boolean isBroadcast;
    
    private LocalDateTime sentAt;
}

