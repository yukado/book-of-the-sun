package dev.yukado.bookofthesun.controller;

import dev.yukado.bookofthesun.domain.SpinResult;
import dev.yukado.bookofthesun.service.SlotService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/slot")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequiredArgsConstructor
public class SlotController {

    private final SlotService slotService;

    @PostMapping("/spin")
    public SpinResult spin(@Valid @RequestBody SpinRequest request) {
        return slotService.spin(request.userId(), request.betAmountInCents());
    }
}

// Request-Record für die Validierung der eingehenden JSON-Daten
record SpinRequest(
        @NotNull(message = "User-ID darf nicht leer sein")
        Long userId,

        @NotNull(message = "Einsatz darf nicht leer sein")
        @Min(value = 1, message = "Einsatz muss mindestens 1 Cent betragen")
        Long betAmountInCents
) {}
