package dev.yukado.bookofthesun.service;

import dev.yukado.bookofthesun.domain.Balance;
import dev.yukado.bookofthesun.repository.BalanceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BalanceService {

    private final BalanceRepository balanceRepository;

    public Balance withdrawForBet(Long userId, Long betAmount) {
        Balance balance = balanceRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Balance not found"));

        if (balance.getAmountInCents() < betAmount) {
            throw new RuntimeException("Insufficient funds");
        }

        balance.setAmountInCents(balance.getAmountInCents() - betAmount);
        return balanceRepository.save(balance);
    }

    public Balance depositWin(Long userId, Long winAmount) {
        Balance balance = balanceRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Balance not found"));

        balance.setAmountInCents(balance.getAmountInCents() + winAmount);
        return balanceRepository.save(balance);
    }

    public Balance getBalance(Long userId) {
        return balanceRepository
                .findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Balance nicht gefunden für User " + userId
                        ));
    }
}
