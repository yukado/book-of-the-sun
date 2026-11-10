package dev.yukado.bookofthesun.service;

import dev.yukado.bookofthesun.domain.FreeSpinFeatureState;
import dev.yukado.bookofthesun.domain.Symbol;
import dev.yukado.bookofthesun.domain.SymbolSet;
import dev.yukado.bookofthesun.domain.User;
import dev.yukado.bookofthesun.repository.FreeSpinFeatureRepository;
import dev.yukado.bookofthesun.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Random;

@Service
@RequiredArgsConstructor
public class FreeSpinFeatureService {

    private final FreeSpinFeatureRepository featureRepository;
    private final UserRepository userRepository;
    private final Random random = new Random();

    public Symbol assignExpandingSymbol(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Symbol symbol = SymbolSet.ALL.stream()
                .filter(s -> s != Symbol.BOOK)
                .toList()
                .get(random.nextInt(SymbolSet.ALL.size() - 1));

        FreeSpinFeatureState state = featureRepository.findByUserId(userId)
                .orElse(FreeSpinFeatureState.builder()
                        .user(user)
                        .build()
                );

        state.setExpandingSymbol(symbol);
        featureRepository.save(state);

        return symbol;
    }

    public Symbol getExpandingSymbol(Long userId) {
        return featureRepository.findByUserId(userId)
                .map(FreeSpinFeatureState::getExpandingSymbol)
                .orElse(null);
    }

    public void clear(Long userId) {
        featureRepository.findByUserId(userId)
                .ifPresent(featureRepository::delete);
    }
}
