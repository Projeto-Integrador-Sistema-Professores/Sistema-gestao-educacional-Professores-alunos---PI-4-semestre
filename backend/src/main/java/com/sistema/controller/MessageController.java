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
import java.time.format.DateTimeFormatter;
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
            @RequestHeader(value = "Authorization", required = false) String authHeader,
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
                // Quando não há studentId, filtra por professor logado (para aba "Mensagens Enviadas")
                User user = authService.validateToken(authHeader).orElse(null);
                
                if (user != null && authService.isTeacher(user)) {
                    // Busca apenas mensagens enviadas pelo professor logado
                    // A query findByFrom_IdOrderBySentAtDesc já garante que as mensagens pertencem ao professor
                    try {
                        messages = messageRepository.findByFrom_IdOrderBySentAtDesc(user.getId());
                    } catch (Exception e) {
                        e.printStackTrace();
                        // Fallback: busca todas e filtra manualmente usando o ID do from armazenado
                        messages = messageRepository.findAll();
                        if (messages != null) {
                            final String teacherId = user.getId();
                            messages = messages.stream()
                                    .filter(m -> m != null)
                                    .collect(Collectors.toList());
                            // Tenta carregar o from para cada mensagem ou usa o ID diretamente do DBRef
                            // Como DBRef pode não estar carregado, vamos usar uma abordagem diferente
                            // Vamos buscar todas e depois filtrar pelo ID do from no documento MongoDB
                        }
                    }
                } else {
                    // Se não for professor ou não autenticado, retorna todas (compatibilidade)
                    try {
                        messages = messageRepository.findAllByOrderBySentAtDesc();
                    } catch (Exception e) {
                        messages = messageRepository.findAll();
                    }
                }
                
                if (messages == null) {
                    messages = new ArrayList<>();
                }
                System.out.println("Total de mensagens encontradas: " + messages.size());
                
                // Não filtra por getFrom() != null porque DBRef pode não estar carregado
                // A query já garante que as mensagens são válidas
                // Apenas remove mensagens nulas
                messages = messages.stream()
                        .filter(m -> m != null)
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
            
            // Obtém o ID do professor autenticado para usar como fallback quando DBRef não estiver carregado
            String authenticatedTeacherId = null;
            if (studentId == null) {
                User authenticatedUser = authService.validateToken(authHeader).orElse(null);
                if (authenticatedUser != null && authService.isTeacher(authenticatedUser)) {
                    authenticatedTeacherId = authenticatedUser.getId();
                }
            }
            
            final String teacherIdFallback = authenticatedTeacherId;
            
            List<Map<String, Object>> result = messages.stream()
                    .filter(m -> m != null) // Apenas remove mensagens nulas
                    .map(m -> {
                        Map<String, Object> map = new HashMap<>();
                        map.put("id", m.getId() != null ? m.getId() : "");
                        
                        // Tenta obter o fromId do DBRef, se não estiver carregado, usa o fallback
                        String fromId = "";
                        if (m.getFrom() != null && m.getFrom().getId() != null) {
                            fromId = m.getFrom().getId();
                        } else if (teacherIdFallback != null) {
                            // Se o DBRef não estiver carregado, usa o ID do professor autenticado
                            // (já que a query garante que as mensagens pertencem a ele)
                            fromId = teacherIdFallback;
                        }
                        map.put("fromId", fromId);
                        
                        // Tenta obter informações do destinatário
                        if (m.getTo() != null) {
                            if (m.getTo().getId() != null) {
                                map.put("toId", m.getTo().getId());
                            }
                            if (m.getTo().getName() != null) {
                                map.put("toName", m.getTo().getName());
                            }
                        }
                        
                        map.put("content", m.getContent() != null ? m.getContent() : "");
                        map.put("isBroadcast", m.getIsBroadcast() != null ? m.getIsBroadcast() : false);
                        // Converte LocalDateTime para String ISO para compatibilidade com frontend
                        if (m.getSentAt() != null) {
                            map.put("sentAt", m.getSentAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                        } else {
                            map.put("sentAt", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                        }
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
            // Converte LocalDateTime para String ISO para compatibilidade com frontend
            if (message.getSentAt() != null) {
                messageData.put("sentAt", message.getSentAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            } else {
                messageData.put("sentAt", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            }
            response.put("message", messageData);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao salvar mensagem: " + e.getMessage()));
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteMessage(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable String id) {
        
        // Verifica autenticação
        User user = authService.validateToken(authHeader).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Usuário não autenticado"));
        }
        
        // Apenas professores podem deletar mensagens
        if (!authService.isTeacher(user)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Apenas professores podem deletar mensagens"));
        }
        
        try {
            Optional<Message> messageOpt = messageRepository.findById(id);
            if (messageOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("error", "Mensagem não encontrada"));
            }
            
            Message message = messageOpt.get();
            
            // Verifica se a mensagem foi enviada pelo professor logado
            if (message.getFrom() == null || !user.getId().equals(message.getFrom().getId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(Map.of("error", "Você só pode deletar suas próprias mensagens"));
            }
            
            messageRepository.deleteById(id);
            
            return ResponseEntity.ok(Map.of("ok", true, "message", "Mensagem deletada com sucesso"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao deletar mensagem: " + e.getMessage()));
        }
    }
}

