package com.sistema.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
    private List<T> items;
    
    public static <T> ApiResponse<T> of(List<T> items) {
        return new ApiResponse<>(items);
    }
}

