package com.sistema.service;

import com.sistema.model.User;
import com.sistema.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Base64;
import java.util.Optional;

@Service
public class AuthService {
    
    @Autowired
    private UserRepository userRepository;
    
    /**
     * Valida o token e retorna o usuário autenticado
     */
    public Optional<User> validateToken(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return Optional.empty();
        }
        
        try {
            String token = authHeader.substring(7); // Remove "Bearer "
            
            // Verifica tokens demo primeiro
            if ("demo_teacher_token".equals(token)) {
                User demoTeacher = new User();
                demoTeacher.setId("demo_teacher_1");
                demoTeacher.setName("Prof. Demo");
                demoTeacher.setRa("123456");
                demoTeacher.setRole("teacher");
                return Optional.of(demoTeacher);
            }
            
            if ("demo_student_token".equals(token)) {
                User demoStudent = new User();
                demoStudent.setId("demo_student_1");
                demoStudent.setName("Aluno Demo");
                demoStudent.setRa("2024001");
                demoStudent.setRole("student");
                return Optional.of(demoStudent);
            }
            
            // Tenta decodificar token real
            String tokenData = new String(Base64.getDecoder().decode(token));
            String[] parts = tokenData.split(":");
            
            if (parts.length != 3) {
                return Optional.empty();
            }
            
            String userId = parts[0];
            return userRepository.findById(userId);
        } catch (Exception e) {
            return Optional.empty();
        }
    }
    
    /**
     * Verifica se o usuário tem a role especificada
     */
    public boolean hasRole(User user, String role) {
        return user != null && role.equals(user.getRole());
    }
    
    /**
     * Verifica se o usuário é um professor
     */
    public boolean isTeacher(User user) {
        return hasRole(user, "teacher");
    }
    
    /**
     * Verifica se o usuário é um aluno
     */
    public boolean isStudent(User user) {
        return hasRole(user, "student");
    }
}

