package dev.yukado.bookofthesun.controller;

import dev.yukado.bookofthesun.dto.UserProfileResponse;
import dev.yukado.bookofthesun.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/user/me")
    public UserProfileResponse getProfile(Authentication auth) {
        String email = (auth != null) ? auth.getName() : "test@user.de"; // Fallback für Entwicklungsmodus
        return userService.getProfile(email);
    }

    @GetMapping("/balance/{userId}")
    public Map<String, Long> getBalance(@PathVariable Long userId) {
        return Map.of("amountInCents", userService.getBalanceInCents(userId));
    }
}
