package dev.yukado.bookofthesun.repository;

import dev.yukado.bookofthesun.domain.FreeSpinFeatureState;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FreeSpinFeatureRepository extends JpaRepository<FreeSpinFeatureState, Long> {
    Optional<FreeSpinFeatureState> findByUserId(Long userId);
}
