package dev.yukado.bookofthesun.service;

import dev.yukado.bookofthesun.domain.*;
import dev.yukado.bookofthesun.dto.*;
import dev.yukado.bookofthesun.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final BalanceRepository balanceRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void register(UserRegistrationRequest request) {
        // KORREKTUR: getEmail() statt email nutzen
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email existiert bereits!");
        }

        // KORREKTUR: getEmail() und getPassword() nutzen
        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role("ROLE_USER")
                .build();

        Balance balance = Balance.builder()
                .amountInCents(50000L)
                .user(user)
                .build();

        user.setBalance(balance);
        userRepository.save(user);
    }

    public UserProfileResponse getProfile(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Nutzer nicht gefunden"));
        return new UserProfileResponse(user.getId(), user.getEmail(), user.getRole());
    }

    public Long getBalanceInCents(Long userId) {
        return balanceRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Konto nicht gefunden"))
                .getAmountInCents();
    }

    // ⭐ NUTZER-ID ANHAND DER EMAIL ERMITTELN
    public Long getUserIdByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Benutzer mit der E-Mail " + email + " wurde nicht gefunden!"))
                .getId();
    }

}
