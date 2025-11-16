package com.sistema.controller;

import com.sistema.dto.UserDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    // Simulação de autenticação - retorna usuário mock
    @GetMapping("/me")
    public ResponseEntity<UserDTO> getCurrentUser() {
        UserDTO user = new UserDTO();
        user.setId("u1");
        user.setName("Prof. João");
        user.setRa("123456");
        user.setRole("teacher");
        return ResponseEntity.ok(user);
    }
}

