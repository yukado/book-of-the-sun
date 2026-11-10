package dev.yukado.bookofthesun.dto;

public record UserProfileResponse(
        Long id,
        String email,
        String role
) {}
