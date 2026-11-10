package dev.yukado.bookofthesun.dto;

import lombok.Data;

@Data
public class UserRegistrationRequest {
    private String email;
    private String password;
}

