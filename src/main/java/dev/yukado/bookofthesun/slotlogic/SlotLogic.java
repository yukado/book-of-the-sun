package dev.yukado.bookofthesun.slotlogic;

import dev.yukado.bookofthesun.domain.SpinResult;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

@Component
public class SlotLogic {

    public static final List<String> SYMBOLS = List.of(
            "BOOK", "EXPLORER", "PHARAOH", "SCARAB", "STATUE", "A", "K", "Q", "J", "TEN"
    );

    private static final List<String> WEIGHTED_POOL = new ArrayList<>();
    private final Random random = new Random();

    static {
        addSymbolToPool("BOOK", 2);
        addSymbolToPool("EXPLORER", 1);
        addSymbolToPool("PHARAOH", 3);
        addSymbolToPool("SCARAB", 4);
        addSymbolToPool("STATUE", 4);
        addSymbolToPool("A", 6);
        addSymbolToPool("K", 6);
        addSymbolToPool("Q", 7);
        addSymbolToPool("J", 8);
        addSymbolToPool("TEN", 8);
    }

    private static void addSymbolToPool(String symbol, int count) {
        for (int i = 0; i < count; i++) {
            WEIGHTED_POOL.add(symbol);
        }
    }

    // ⭐ ERWEITERT: Akzeptiert nun den aktuellen Freispiel-Status aus der DB
    public SpinResult spin(long lineBetInCents, int currentFreeSpinsLeft, String activeSpecialSymbol) {
        List<List<String>> reels = new ArrayList<>();

        // 1. Walzen befüllen
        for (int i = 0; i < 5; i++) {
            List<String> singleReel = new ArrayList<>();
            for (int j = 0; j < 3; j++) {
                int randomIndex = random.nextInt(WEIGHTED_POOL.size());
                singleReel.add(WEIGHTED_POOL.get(randomIndex));
            }
            reels.add(singleReel);
        }

        int totalWinAmount = 0;
        boolean freeSpinsTriggeredThisSpin = false;
        int newFreeSpinsLeft = currentFreeSpinsLeft;
        String nextSpecialSymbol = activeSpecialSymbol;
        Set<String> winningPositions = new HashSet<>();
        List<String> lineWins = new ArrayList<>();
        List<Integer> expandingRows = new ArrayList<>();

        // --- A. SCATTER-AUSWERTUNG (BOOKs) ---
        List<String> bookPositionsThisSpin = new ArrayList<>();
        for (int reelIdx = 0; reelIdx < reels.size(); reelIdx++) {
            for (int rowIdx = 0; rowIdx < reels.get(reelIdx).size(); rowIdx++) {
                if ("BOOK".equals(reels.get(reelIdx).get(rowIdx))) {
                    bookPositionsThisSpin.add(reelIdx + "," + rowIdx);
                }
            }
        }

        // Trigger für Freispiele (3+ Bücher)
        if (bookPositionsThisSpin.size() >= 3) {
            freeSpinsTriggeredThisSpin = true;
            newFreeSpinsLeft += 10; // 10 Freispiele gutschreiben
            winningPositions.addAll(bookPositionsThisSpin);

            long totalBet = lineBetInCents * 5;
            int scatterWin = (int) (totalBet * 2);
            totalWinAmount += scatterWin;
            lineWins.add("Scatter: +" + (scatterWin / 100) + "€");

            // ⭐ Sondersymbol bestimmen (Darf kein BOOK sein)
            if (nextSpecialSymbol == null || nextSpecialSymbol.isEmpty()) {
                List<String> validSpecialSymbols = new ArrayList<>(SYMBOLS);
                validSpecialSymbols.remove("BOOK");
                nextSpecialSymbol = validSpecialSymbols.get(random.nextInt(validSpecialSymbols.size()));
            }
        }

        // --- B. NORMALE LINIEN-AUSWERTUNG ---
        int[][] paylines = {
                {0, 0, 0, 0, 0}, {1, 1, 1, 1, 1}, {2, 2, 2, 2, 2},
                {0, 1, 2, 1, 0}, {2, 1, 0, 1, 2}
        };

        int lineId = 1;
        for (int[] line : paylines) {
            String startSymbol = reels.get(0).get(line[0]);
            int matchCount = 1;

            for (int reelIdx = 1; reelIdx < 5; reelIdx++) {
                if (reels.get(reelIdx).get(line[reelIdx]).equals(startSymbol)) {
                    matchCount++;
                } else {
                    break;
                }
            }

            if (!"BOOK".equals(startSymbol)) {
                boolean isHighSymbol = "EXPLORER".equals(startSymbol) || "PHARAOH".equals(startSymbol)
                        || "SCARAB".equals(startSymbol) || "STATUE".equals(startSymbol);
                boolean isWin = (isHighSymbol && matchCount >= 2) || (!isHighSymbol && matchCount >= 3);

                if (isWin) {
                    int winForThisLine = calculateLineWin(startSymbol, matchCount, lineBetInCents);
                    totalWinAmount += winForThisLine;
                    lineWins.add("L" + lineId + ": +" + (winForThisLine / 100) + "€");

                    for (int i = 0; i < matchCount; i++) {
                        winningPositions.add(i + "," + line[i]);
                    }
                }
            }
            lineId++;
        }

        // --- C. SPECIAL SYMBOL EXPANSION LOGIK (NUR WÄHREND FREISPIELEN) ---
        if (currentFreeSpinsLeft > 0 && nextSpecialSymbol != null) {
            Set<Integer> foundExpandingRows = new HashSet<>();

// Prüfen in welchen Zeilen das Sondersymbol vorkommt
            for (int reelIdx = 0; reelIdx < reels.size(); reelIdx++) {

                List<String> reel = reels.get(reelIdx);

                for (int rowIdx = 0; rowIdx < reel.size(); rowIdx++) {

                    if (nextSpecialSymbol.equals(reel.get(rowIdx))) {
                        foundExpandingRows.add(rowIdx);
                    }
                }
            }

            // Book of Ra Logik: High-Symbole expandieren ab 2 Walzen, Low-Symbole ab 3 Walzen
            if (!foundExpandingRows.isEmpty()) {

                int totalExpansionWin = 0;

                for (Integer rowIdx : foundExpandingRows) {
                    expandingRows.addAll(foundExpandingRows);

                    // Reihe komplett mit Special Symbol füllen
                    for (int reelIdx = 0; reelIdx < reels.size(); reelIdx++) {
                        winningPositions.add(reelIdx + "," + rowIdx);
                    }

                    // Gewinn nur für diese eine Reihe berechnen
                    int lineWin = calculateLineWin(
                            nextSpecialSymbol,
                            5,
                            lineBetInCents
                    );

                    totalExpansionWin += lineWin;
                }

                totalWinAmount += totalExpansionWin;

                lineWins.add(
                        "Expansion (" + nextSpecialSymbol + "): +"
                                + (totalExpansionWin / 100)
                                + "€"
                );
            }

            // Freispielzähler verringern
            newFreeSpinsLeft--;

            // Wenn Freispiele verbraucht sind, Sondersymbol zurücksetzen
            if (newFreeSpinsLeft == 0) {
                nextSpecialSymbol = null;
            }
        }

        return new SpinResult(reels, winningPositions, totalWinAmount, newFreeSpinsLeft,
                freeSpinsTriggeredThisSpin, 0L, lineWins, nextSpecialSymbol, expandingRows);
    }

    private int calculateLineWin(String symbol, int matchCount, long lineBetInCents) {
        int factor = switch (symbol) {
            case "EXPLORER" -> switch (matchCount) { case 2 -> 10; case 3 -> 100; case 4 -> 1000; default -> 5000; };
            case "PHARAOH" -> switch (matchCount) { case 2 -> 5; case 3 -> 40; case 4 -> 400; default -> 2000; };
            case "SCARAB", "STATUE" -> switch (matchCount) { case 2 -> 5; case 3 -> 30; case 4 -> 100; default -> 750; };
            case "A", "K" -> switch (matchCount) { case 3 -> 5; case 4 -> 40; default -> 150; };
            default -> switch (matchCount) { case 3 -> 5; case 4 -> 25; default -> 100; };
        };
        return (int) (factor * lineBetInCents);
    }
}
