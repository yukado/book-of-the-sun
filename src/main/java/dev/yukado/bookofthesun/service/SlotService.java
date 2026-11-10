package dev.yukado.bookofthesun.service;

import dev.yukado.bookofthesun.domain.Balance;
import dev.yukado.bookofthesun.domain.User;
import dev.yukado.bookofthesun.domain.SpinResult;
import dev.yukado.bookofthesun.domain.Game; // ⭐ Dein Game-Modell importiert
import dev.yukado.bookofthesun.repository.BalanceRepository;
import dev.yukado.bookofthesun.repository.UserRepository;
import dev.yukado.bookofthesun.repository.GameRepository; // ⭐ NEU: Repository für das Game-Modell
import dev.yukado.bookofthesun.slotlogic.SlotLogic;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SlotService {

    private final SlotLogic slotLogic;
    private final BalanceRepository balanceRepository;
    private final UserRepository userRepository;
    private final GameRepository gameRepository; // ⭐ NEU injiziert

    @Transactional
    public SpinResult spin(Long userId, Long betAmountInCents) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User existiert nicht"));

        Balance balance = balanceRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Konto fehlt"));

        // 1. Holt den existierenden Spielzustand oder legt einmalig einen an
        Game game = gameRepository.findByUserId(userId)
                .orElseGet(() -> {
                    Game newGame = new Game(userId, balance.getAmountInCents(), 0, 0, null);
                    return gameRepository.save(newGame);
                });

        int currentFreeSpins = balance.getFreeSpins() != null ? balance.getFreeSpins() : 0;
        boolean isInFreeSpins = currentFreeSpins > 0;

        // Einsatz-Logik
        if (!isInFreeSpins) {
            if (balance.getAmountInCents() < betAmountInCents) {
                throw new RuntimeException("Guthaben unzureichend!");
            }
            balance.setAmountInCents(balance.getAmountInCents() - betAmountInCents);
        }

        // 2. Linieneinsatz berechnen & an SlotLogic übergeben
        long lineBetInCents = betAmountInCents / 5;
        SpinResult rawResult = slotLogic.spin(lineBetInCents, currentFreeSpins, game.getSpecialSymbol());

        // 3. Freispiel-Status in die Balance-Tabelle übernehmen
        balance.setFreeSpins(rawResult.getFreeSpinsLeft());
        balance.setAmountInCents(balance.getAmountInCents() + rawResult.getWinAmount());
        balanceRepository.save(balance);

        // =========================================================================
        // ⭐ KORREKTUR: Bestehendes Game-Objekt verändern statt neu erzeugen!
        // =========================================================================
        game.setBalance(balance.getAmountInCents() / 100.0);
        game.setLastWin(rawResult.getWinAmount() / 100);
        game.setFreeSpins(rawResult.getFreeSpinsLeft());
        game.setSpecialSymbol(rawResult.getSpecialSymbol()); // Aktualisiert das Sondersymbol

        // Führt nun ein sicheres SQL-UPDATE auf die bestehende ID aus:
        gameRepository.save(game);
        // =========================================================================

        // 5. Sauberes Paket für das Frontend schnüren
        return new SpinResult(
                rawResult.getReels(),
                rawResult.getWinningPositions(),
                rawResult.getWinAmount(),
                balance.getFreeSpins(),
                rawResult.isFreeSpinsTriggered(),
                balance.getAmountInCents(),
                rawResult.getLineWins(),
                game.getSpecialSymbol(),
                rawResult.getExpandingRows()
        );
    }
}
