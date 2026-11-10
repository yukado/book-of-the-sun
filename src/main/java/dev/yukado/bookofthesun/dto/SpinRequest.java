package dev.yukado.bookofthesun.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record SpinRequest(
        @JsonProperty("userId")
        @NotNull(message = "userId darf nicht null sein")
        Long userId,

        @JsonProperty("betAmountInCents") // Erzwingt diesen exakten Namen im JSON!
        @NotNull(message = "Einsatz darf nicht null sein")
        @Min(10) // Verhindert fehlerhafte Einsätze
        Long betAmountInCents
) {}

