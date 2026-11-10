package dev.yukado.bookofthesun.dto;

public record AuthResponse(
        String token,
        Long userId,
        String username
) {}
