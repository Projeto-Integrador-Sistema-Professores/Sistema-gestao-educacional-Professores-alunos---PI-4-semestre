package com.sistema.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessageDTO {
    private String id;
    private String fromId;
    private String toId;
    private String toName;
    private String content;
    private Boolean isBroadcast;
    private LocalDateTime sentAt;
}

