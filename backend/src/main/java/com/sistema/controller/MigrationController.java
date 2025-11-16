package com.sistema.controller;

import com.sistema.service.MigrationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/migration")
public class MigrationController {
    
    @Autowired
    private MigrationService migrationService;
    
    @PostMapping("/import")
    public ResponseEntity<Map<String, String>> importData(@RequestBody Map<String, Object> data) {
        try {
            migrationService.migrateFromJson(data);
            return ResponseEntity.ok(Map.of("status", "success", "message", "Dados migrados com sucesso"));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(Map.of("status", "error", "message", e.getMessage()));
        }
    }
}

