package dev.yukado.bookofthesun.controller;

import dev.yukado.bookofthesun.domain.Balance;
import dev.yukado.bookofthesun.service.BalanceService;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/balance")
@RequiredArgsConstructor
public class BalanceController {

    private final BalanceService balanceService;

    @PostMapping("/{userId}/deposit")
    public Balance deposit(
            @PathVariable Long userId,
            @RequestParam @Min(1) Long amountInCents
    ) {
        return balanceService.depositWin(userId, amountInCents);
    }

    @PostMapping("/{userId}/withdraw")
    public Balance withdraw(
            @PathVariable Long userId,
            @RequestParam @Min(1) Long amountInCents
    ) {
        return balanceService.withdrawForBet(userId, amountInCents);
    }

}
