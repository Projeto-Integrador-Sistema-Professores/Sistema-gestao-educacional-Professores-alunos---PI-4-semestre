package com.sistema.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {
    private String username; // Para alunos: nome@poliedro, para professores: RA
    private String password; // Para alunos: RA, para professores: senha
}

