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

