package dev.yukado.bookofthesun.service;

import dev.yukado.bookofthesun.domain.User;
import dev.yukado.bookofthesun.domain.Balance;
import dev.yukado.bookofthesun.dto.AuthResponse;
import dev.yukado.bookofthesun.dto.UserLoginRequest;
import dev.yukado.bookofthesun.dto.UserRegistrationRequest;
import dev.yukado.bookofthesun.repository.UserRepository;
import dev.yukado.bookofthesun.repository.BalanceRepository;
import dev.yukado.bookofthesun.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final BalanceRepository balanceRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    // ⭐ REGISTRIERUNG OHNE USERNAME
    public AuthResponse register(UserRegistrationRequest request) {

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role("ROLE_USER")
                .build();

        userRepository.save(user);

        Balance balance = Balance.builder()
                .user(user)
                .amountInCents(50000L)
                .build();

        balanceRepository.save(balance);

        String token = jwtService.generateToken(user.getEmail());

        return new AuthResponse(
                token,
                user.getId(),
                user.getEmail()
        );
    }

    // ⭐ LOGIN OHNE USERNAME
    public AuthResponse login(UserLoginRequest request) {

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        String token = jwtService.generateToken(user.getEmail());

        return new AuthResponse(token,
                user.getId(),
                user.getEmail()
        );
    }
}
