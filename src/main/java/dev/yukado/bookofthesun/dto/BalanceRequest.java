package dev.yukado.bookofthesun.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record BalanceRequest(
        @NotNull Long userId,
        @Min(1) Long amountInCents
) {}
