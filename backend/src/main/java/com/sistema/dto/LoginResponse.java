package com.sistema.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {
    private boolean success;
    private String token;
    private UserDTO user;
    private String message;
    
    public static LoginResponse success(String token, UserDTO user) {
        return new LoginResponse(true, token, user, "Login realizado com sucesso");
    }
    
    public static LoginResponse failure(String message) {
        return new LoginResponse(false, null, null, message);
    }
}

