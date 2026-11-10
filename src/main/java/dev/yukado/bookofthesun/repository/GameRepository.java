package dev.yukado.bookofthesun.repository;

import dev.yukado.bookofthesun.domain.Game;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GameRepository extends JpaRepository<Game, Long> {

    /**
     * Findet den aktuellen Spielzustand (inkl. Sondersymbol) eines bestimmten Nutzers.
     *
     * @param userId die ID des Users
     * @return ein Optional mit dem Game-Zustand, falls vorhanden
     */
    Optional<Game> findByUserId(Long userId);
}
