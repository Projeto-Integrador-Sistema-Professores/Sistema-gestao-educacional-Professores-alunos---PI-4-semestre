package com.sistema.controller;

import com.sistema.dto.ApiResponse;
import com.sistema.model.Message;
import com.sistema.model.User;
import com.sistema.repository.MessageRepository;
import com.sistema.repository.UserRepository;
import com.sistema.service.AuthService;
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
    
    @Autowired
    private AuthService authService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMessages(
            @RequestParam(value = "studentId", required = false) String studentId) {
        
        try {
            List<Message> messages;
            
            if (studentId != null && !studentId.isEmpty()) {
                // Mensagens para um aluno específico (incluindo broadcasts)
                List<Message> directMessages = messageRepository.findByTo_IdOrderBySentAtDesc(studentId);
                List<Message> broadcastMessages = messageRepository.findByIsBroadcastTrueOrderBySentAtDesc();
                
                Set<String> seenIds = new HashSet<>();
                messages = new ArrayList<>();
                
                if (directMessages != null) {
                    for (Message msg : directMessages) {
                        if (msg != null && msg.getId() != null && !seenIds.contains(msg.getId())) {
                            messages.add(msg);
                            seenIds.add(msg.getId());
                        }
                    }
                }
                
                if (broadcastMessages != null) {
                    for (Message msg : broadcastMessages) {
                        if (msg != null && msg.getId() != null && !seenIds.contains(msg.getId())) {
                            messages.add(msg);
                            seenIds.add(msg.getId());
                        }
                    }
                }
                
                // Ordena por data
                if (messages != null && !messages.isEmpty()) {
                    messages.sort((a, b) -> {
                        if (a.getSentAt() == null || b.getSentAt() == null) {
                            return 0;
                        }
                        return b.getSentAt().compareTo(a.getSentAt());
                    });
                }
            } else {
                // Todas as mensagens - busca todas ordenadas por data
                try {
                    messages = messageRepository.findAllByOrderBySentAtDesc();
                } catch (Exception e) {
                    // Fallback para findAll se o método customizado não funcionar
                    messages = messageRepository.findAll();
                }
                
                if (messages == null) {
                    messages = new ArrayList<>();
                }
                System.out.println("Total de mensagens encontradas: " + messages.size());
                
                // Filtra mensagens inválidas antes de processar
                messages = messages.stream()
                        .filter(m -> m != null && m.getFrom() != null)
                        .collect(Collectors.toList());
                
                System.out.println("Mensagens válidas após filtro: " + messages.size());
                
                // Ordena manualmente por garantia (mais recente primeiro)
                if (!messages.isEmpty()) {
                    messages.sort((a, b) -> {
                        if (a.getSentAt() == null || b.getSentAt() == null) {
                            return 0;
                        }
                        return b.getSentAt().compareTo(a.getSentAt());
                    });
                }
            }
            
            List<Map<String, Object>> result = messages.stream()
                    .filter(m -> m != null && m.getFrom() != null) // Filtra mensagens inválidas
                    .map(m -> {
                        Map<String, Object> map = new HashMap<>();
                        map.put("id", m.getId() != null ? m.getId() : "");
                        if (m.getFrom() != null) {
                            map.put("fromId", m.getFrom().getId() != null ? m.getFrom().getId() : "");
                        } else {
                            map.put("fromId", "");
                        }
                        if (m.getTo() != null) {
                            map.put("toId", m.getTo().getId() != null ? m.getTo().getId() : "");
                            map.put("toName", m.getTo().getName() != null ? m.getTo().getName() : "");
                        }
                        map.put("content", m.getContent() != null ? m.getContent() : "");
                        map.put("isBroadcast", m.getIsBroadcast() != null ? m.getIsBroadcast() : false);
                        map.put("sentAt", m.getSentAt() != null ? m.getSentAt() : LocalDateTime.now());
                        return map;
                    })
                    .collect(Collectors.toList());
            
            return ResponseEntity.ok(ApiResponse.of(result));
        } catch (Exception e) {
            e.printStackTrace();
            // Retorna lista vazia em caso de erro
            return ResponseEntity.ok(ApiResponse.of(new ArrayList<>()));
        }
    }
    
    @PostMapping
    public ResponseEntity<Map<String, Object>> createMessage(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestBody Map<String, Object> data) {
        
        // Verifica autenticação
        User user = authService.validateToken(authHeader).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Usuário não autenticado"));
        }
        
        // Apenas professores podem enviar mensagens
        if (!authService.isTeacher(user)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Apenas professores podem enviar mensagens"));
        }
        
        String toId = (String) data.get("toId");
        String content = (String) data.get("content");
        Boolean isBroadcast = (Boolean) data.getOrDefault("isBroadcast", false);
        
        if (content == null || content.trim().isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Conteúdo da mensagem é obrigatório"));
        }
        
        Message message = new Message();
        message.setId(UUID.randomUUID().toString());
        message.setFrom(user); // Usa o usuário autenticado
        
        if (toId != null && !toId.isEmpty() && !isBroadcast) {
            Optional<User> toOpt = userRepository.findById(toId);
            if (toOpt.isPresent()) {
                // Verifica se o destinatário é um aluno
                if (!"student".equals(toOpt.get().getRole())) {
                    return ResponseEntity.badRequest()
                            .body(Map.of("error", "Destinatário deve ser um aluno"));
                }
                message.setTo(toOpt.get());
            }
        }
        
        message.setContent(content.trim());
        message.setIsBroadcast(isBroadcast != null && isBroadcast);
        message.setSentAt(LocalDateTime.now());
        
        try {
            message = messageRepository.save(message);
            System.out.println("Mensagem salva com ID: " + message.getId());
            System.out.println("From: " + (message.getFrom() != null ? message.getFrom().getId() : "null"));
            System.out.println("To: " + (message.getTo() != null ? message.getTo().getId() : "null"));
            System.out.println("Broadcast: " + message.getIsBroadcast());
            
            // Recarrega a mensagem para garantir que os DBRefs estejam carregados
            Optional<Message> savedMessageOpt = messageRepository.findById(message.getId());
            if (savedMessageOpt.isPresent()) {
                message = savedMessageOpt.get();
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("ok", true);
            Map<String, Object> messageData = new HashMap<>();
            messageData.put("id", message.getId());
            if (message.getFrom() != null) {
                messageData.put("fromId", message.getFrom().getId());
            } else {
                messageData.put("fromId", user.getId()); // Fallback para o usuário autenticado
            }
            if (message.getTo() != null) {
                messageData.put("toId", message.getTo().getId());
                messageData.put("toName", message.getTo().getName());
            }
            messageData.put("content", message.getContent());
            messageData.put("isBroadcast", message.getIsBroadcast() != null ? message.getIsBroadcast() : false);
            messageData.put("sentAt", message.getSentAt() != null ? message.getSentAt() : LocalDateTime.now());
            response.put("message", messageData);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao salvar mensagem: " + e.getMessage()));
        }
    }
}

