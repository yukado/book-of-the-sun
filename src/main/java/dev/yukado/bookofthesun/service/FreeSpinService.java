package dev.yukado.bookofthesun.service;

import dev.yukado.bookofthesun.domain.FreeSpinState;
import dev.yukado.bookofthesun.domain.User;
import dev.yukado.bookofthesun.repository.FreeSpinRepository;
import dev.yukado.bookofthesun.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FreeSpinService {

    private final FreeSpinRepository freeSpinRepository;
    private final UserRepository userRepository;

    public boolean consumeFreeSpin(Long userId) {
        FreeSpinState state = freeSpinRepository.findByUserId(userId)
                .orElse(null);

        if (state == null || state.getRemainingFreeSpins() <= 0) {
            return false;
        }

        state.setRemainingFreeSpins(state.getRemainingFreeSpins() - 1);
        freeSpinRepository.save(state);
        return true;
    }

    public void grantFreeSpins(Long userId, int count) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        FreeSpinState state = freeSpinRepository.findByUserId(userId)
                .orElse(FreeSpinState.builder()
                        .user(user)
                        .remainingFreeSpins(0)
                        .build()
                );

        state.setRemainingFreeSpins(state.getRemainingFreeSpins() + count);
        freeSpinRepository.save(state);
    }

    public int getRemainingFreeSpins(Long userId) {
        return freeSpinRepository.findByUserId(userId)
                .map(FreeSpinState::getRemainingFreeSpins)
                .orElse(0);
    }
}
