package com.sistema.controller;

import com.sistema.dto.LoginRequest;
import com.sistema.dto.LoginResponse;
import com.sistema.dto.UserDTO;
import com.sistema.model.User;
import com.sistema.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Base64;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @Autowired
    private UserRepository userRepository;
    
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        if (request.getUsername() == null || request.getPassword() == null) {
            return ResponseEntity.badRequest()
                    .body(LoginResponse.failure("Username e senha são obrigatórios"));
        }
        
        // Credenciais demo para aluno
        if ("demo@poliedro".equals(request.getUsername()) && "demo".equals(request.getPassword())) {
            UserDTO userDTO = new UserDTO();
            userDTO.setId("demo_student_1");
            userDTO.setName("Aluno Demo");
            userDTO.setRa("2024001");
            userDTO.setRole("student");
            
            String tokenData = userDTO.getId() + ":" + userDTO.getRole() + ":" + userDTO.getRa();
            String token = Base64.getEncoder().encodeToString(tokenData.getBytes());
            
            return ResponseEntity.ok(LoginResponse.success(token, userDTO));
        }
        
        // Credenciais demo para professor
        if ("demo".equals(request.getUsername()) && "demo".equals(request.getPassword())) {
            UserDTO userDTO = new UserDTO();
            userDTO.setId("demo_teacher_1");
            userDTO.setName("Prof. Demo");
            userDTO.setRa("123456");
            userDTO.setRole("teacher");
            
            String tokenData = userDTO.getId() + ":" + userDTO.getRole() + ":" + userDTO.getRa();
            String token = Base64.getEncoder().encodeToString(tokenData.getBytes());
            
            return ResponseEntity.ok(LoginResponse.success(token, userDTO));
        }
        
        // Verifica se é login de aluno (formato: nome@poliedro)
        if (request.getUsername().endsWith("@poliedro")) {
            // Extrai o nome do aluno (remove @poliedro)
            String studentName = request.getUsername().substring(0, request.getUsername().length() - 10);
            String ra = request.getPassword();
            
            // Busca aluno pelo RA
            Optional<User> userOpt = userRepository.findByRa(ra);
            
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(401)
                        .body(LoginResponse.failure("RA não encontrado"));
            }
            
            User user = userOpt.get();
            
            // Verifica se é realmente um aluno
            if (!"student".equals(user.getRole())) {
                return ResponseEntity.status(401)
                        .body(LoginResponse.failure("Usuário não é um aluno"));
            }
            
            // Verifica se o nome corresponde (case-insensitive)
            if (!user.getName().equalsIgnoreCase(studentName)) {
                return ResponseEntity.status(401)
                        .body(LoginResponse.failure("Nome de usuário incorreto"));
            }
            
            // Gera token simples (Base64 do id:role:ra)
            String tokenData = user.getId() + ":" + user.getRole() + ":" + user.getRa();
            String token = Base64.getEncoder().encodeToString(tokenData.getBytes());
            
            // Cria UserDTO
            UserDTO userDTO = new UserDTO();
            userDTO.setId(user.getId());
            userDTO.setName(user.getName());
            userDTO.setRa(user.getRa());
            userDTO.setRole(user.getRole());
            
            return ResponseEntity.ok(LoginResponse.success(token, userDTO));
        } else {
            // Login de professor (usa RA como username e password)
            String ra = request.getUsername();
            
            Optional<User> userOpt = userRepository.findByRa(ra);
            
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(401)
                        .body(LoginResponse.failure("RA não encontrado"));
            }
            
            User user = userOpt.get();
            
            // Verifica se é professor
            if (!"teacher".equals(user.getRole())) {
                return ResponseEntity.status(401)
                        .body(LoginResponse.failure("Usuário não é um professor"));
            }
            
            // Para professores, por enquanto aceita qualquer senha (pode melhorar depois)
            // ou pode validar se password == ra (conforme necessário)
            
            // Gera token simples
            String tokenData = user.getId() + ":" + user.getRole() + ":" + user.getRa();
            String token = Base64.getEncoder().encodeToString(tokenData.getBytes());
            
            // Cria UserDTO
            UserDTO userDTO = new UserDTO();
            userDTO.setId(user.getId());
            userDTO.setName(user.getName());
            userDTO.setRa(user.getRa());
            userDTO.setRole(user.getRole());
            
            return ResponseEntity.ok(LoginResponse.success(token, userDTO));
        }
    }
    
    @GetMapping("/me")
    public ResponseEntity<UserDTO> getCurrentUser(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        // Se não tiver header, retorna mock (compatibilidade)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            UserDTO user = new UserDTO();
            user.setId("demo_teacher_1");
            user.setName("Prof. Demo");
            user.setRa("123456");
            user.setRole("teacher");
            return ResponseEntity.ok(user);
        }
        
        // Verifica tokens demo
        String token = authHeader.substring(7); // Remove "Bearer "
        
        if ("demo_student_token".equals(token)) {
            UserDTO userDTO = new UserDTO();
            userDTO.setId("demo_student_1");
            userDTO.setName("Aluno Demo");
            userDTO.setRa("2024001");
            userDTO.setRole("student");
            return ResponseEntity.ok(userDTO);
        }
        
        if ("demo_teacher_token".equals(token)) {
            UserDTO userDTO = new UserDTO();
            userDTO.setId("demo_teacher_1");
            userDTO.setName("Prof. Demo");
            userDTO.setRa("123456");
            userDTO.setRole("teacher");
            return ResponseEntity.ok(userDTO);
        }
        
        // Decodifica token real
        try {
            String tokenData = new String(Base64.getDecoder().decode(token));
            String[] parts = tokenData.split(":");
            
            if (parts.length != 3) {
                return ResponseEntity.status(401).build();
            }
            
            String userId = parts[0];
            Optional<User> userOpt = userRepository.findById(userId);
            
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(401).build();
            }
            
            User user = userOpt.get();
            UserDTO userDTO = new UserDTO();
            userDTO.setId(user.getId());
            userDTO.setName(user.getName());
            userDTO.setRa(user.getRa());
            userDTO.setRole(user.getRole());
            
            return ResponseEntity.ok(userDTO);
        } catch (Exception e) {
            return ResponseEntity.status(401).build();
        }
    }
}

