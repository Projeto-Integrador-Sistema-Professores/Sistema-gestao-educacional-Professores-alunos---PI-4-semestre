package com.sistema.controller;

import com.sistema.dto.ApiResponse;
import com.sistema.model.Message;
import com.sistema.model.User;
import com.sistema.repository.MessageRepository;
import com.sistema.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.util.UUID;

@RestController
@RequestMapping("/api/messages")
public class MessageController {
    
    @Autowired
    private MessageRepository messageRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @GetMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMessages(
            @RequestParam(value = "studentId", required = false) String studentId) {
        
        List<Message> messages;
        
        if (studentId != null && !studentId.isEmpty()) {
            // Mensagens para um aluno específico (incluindo broadcasts)
            List<Message> directMessages = messageRepository.findByTo_IdOrderBySentAtDesc(studentId);
            List<Message> broadcastMessages = messageRepository.findByIsBroadcastTrueOrderBySentAtDesc();
            
            Set<String> seenIds = new HashSet<>();
            messages = new ArrayList<>();
            
            for (Message msg : directMessages) {
                if (!seenIds.contains(msg.getId())) {
                    messages.add(msg);
                    seenIds.add(msg.getId());
                }
            }
            
            for (Message msg : broadcastMessages) {
                if (!seenIds.contains(msg.getId())) {
                    messages.add(msg);
                    seenIds.add(msg.getId());
                }
            }
            
            // Ordena por data
            messages.sort((a, b) -> b.getSentAt().compareTo(a.getSentAt()));
        } else {
            // Todas as mensagens
            messages = messageRepository.findAll();
            messages.sort((a, b) -> b.getSentAt().compareTo(a.getSentAt()));
        }
        
        List<Map<String, Object>> result = messages.stream()
                .map(m -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", m.getId());
                    map.put("fromId", m.getFrom().getId());
                    if (m.getTo() != null) {
                        map.put("toId", m.getTo().getId());
                        map.put("toName", m.getTo().getName());
                    }
                    map.put("content", m.getContent());
                    map.put("isBroadcast", m.getIsBroadcast());
                    map.put("sentAt", m.getSentAt());
                    return map;
                })
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(ApiResponse.of(result));
    }
    
    @PostMapping
    public ResponseEntity<Map<String, Object>> createMessage(@RequestBody Map<String, Object> data) {
        String fromId = (String) data.get("fromId");
        String toId = (String) data.get("toId");
        String content = (String) data.get("content");
        Boolean isBroadcast = (Boolean) data.getOrDefault("isBroadcast", false);
        
        Optional<User> fromOpt = userRepository.findById(fromId);
        if (fromOpt.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        
        Message message = new Message();
        message.setId(UUID.randomUUID().toString());
        message.setFrom(fromOpt.get());
        
        if (toId != null && !toId.isEmpty() && !isBroadcast) {
            Optional<User> toOpt = userRepository.findById(toId);
            if (toOpt.isPresent()) {
                message.setTo(toOpt.get());
            }
        }
        
        message.setContent(content);
        message.setIsBroadcast(isBroadcast != null && isBroadcast);
        message.setSentAt(LocalDateTime.now());
        
        message = messageRepository.save(message);
        
        Map<String, Object> response = new HashMap<>();
        response.put("ok", true);
        Map<String, Object> messageData = new HashMap<>();
        messageData.put("id", message.getId());
        messageData.put("fromId", message.getFrom().getId());
        if (message.getTo() != null) {
            messageData.put("toId", message.getTo().getId());
            messageData.put("toName", message.getTo().getName());
        }
        messageData.put("content", message.getContent());
        messageData.put("isBroadcast", message.getIsBroadcast());
        messageData.put("sentAt", message.getSentAt());
        response.put("message", messageData);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}

