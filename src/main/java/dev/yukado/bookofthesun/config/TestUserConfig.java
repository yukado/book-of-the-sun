package dev.yukado.bookofthesun.config;

import dev.yukado.bookofthesun.domain.Balance;
import dev.yukado.bookofthesun.domain.User;
import dev.yukado.bookofthesun.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@RequiredArgsConstructor
public class TestUserConfig {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner initializeTestUser() {
        return args -> {
            String testEmail = "test@test.com";

            // Prüfen, ob der User bereits in der H2-Datenbank existiert
            if (userRepository.findByEmail(testEmail).isEmpty()) {

                // 1. User Objekt mit Passwort "12345678" bauen
                User testUser = User.builder()
                        .email(testEmail)
                        .password(passwordEncoder.encode("12345678"))
                        .role("ROLE_USER")
                        .build();

                // 2. Startguthaben von 1.000,00 € (100.000 Cents) zuweisen
                Balance testBalance = Balance.builder()
                        .amountInCents(100000L)
                        .freeSpins(0) // ⭐ HIER REINSETZEN! Verhindert die NULL-Exception
                        .user(testUser)
                        .build();

                testUser.setBalance(testBalance);

                // 3. In H2 speichern
                userRepository.save(testUser);
                System.out.println("⭐ Test-User (test@test.com) mit 1.000,00 € Guthaben wurde erfolgreich in H2 erstellt!");
            } else {
                System.out.println("ℹ️ Test-User existiert bereits in der Datenbank.");
            }
        };
    }
}
