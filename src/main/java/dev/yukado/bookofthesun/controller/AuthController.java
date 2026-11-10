package dev.yukado.bookofthesun.controller;

import dev.yukado.bookofthesun.dto.AuthResponse;
import dev.yukado.bookofthesun.dto.UserLoginRequest;
import dev.yukado.bookofthesun.dto.UserRegistrationRequest;
import dev.yukado.bookofthesun.security.JwtService;
import dev.yukado.bookofthesun.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    @PostMapping("/register")
    public void register(@RequestBody UserRegistrationRequest request) {
        userService.register(request);
    }

    // Injiziere das JwtService oben im AuthController über deinen Konstruktor oder @RequiredArgsConstructor
    private final JwtService jwtService;

    @PostMapping("/login")
    public AuthResponse login(@RequestBody UserLoginRequest request) {
        // ⭐ ECHTES JWT-TOKEN GENERIEREN (Verhindert den Auth-Fehler im SlotScreen)
        String token = jwtService.generateToken(request.getEmail());

        Long userId = userService.getUserIdByEmail(request.getEmail());
        String username = request.getEmail();

        return new AuthResponse(token, userId, username);
    }

}
