package dev.yukado.bookofthesun.repository;

import dev.yukado.bookofthesun.domain.FreeSpinState;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FreeSpinRepository extends JpaRepository<FreeSpinState, Long> {
    Optional<FreeSpinState> findByUserId(Long userId);
}
