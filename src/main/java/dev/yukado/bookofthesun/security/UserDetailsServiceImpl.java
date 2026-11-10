package dev.yukado.bookofthesun.security;

import dev.yukado.bookofthesun.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        // 1. Deinen eigenen User aus der Datenbank laden
        dev.yukado.bookofthesun.domain.User domainUser = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User mit E-Mail " + email + " nicht gefunden"));

        // 2. KORREKTUR: Deinen User in das geforderte Spring-Security 'UserDetails' Objekt umwandeln
        return new org.springframework.security.core.userdetails.User(
                domainUser.getEmail(),
                domainUser.getPassword(),
                List.of(new SimpleGrantedAuthority(domainUser.getRole())) // Wandelt die Rolle (z.B. ROLE_USER) in eine Authority um
        );
    }
}
