package dev.yukado.bookofthesun.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record FreeSpinGrantRequest(
        @NotNull Long userId,
        @Min(1) int count
) {}
