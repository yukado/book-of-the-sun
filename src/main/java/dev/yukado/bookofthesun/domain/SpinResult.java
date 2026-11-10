package dev.yukado.bookofthesun.domain;

import java.util.List;
import java.util.Set;

public class SpinResult {
    private final List<List<String>> reels;
    private final Set<String> winningPositions;
    private final int winAmount;
    private final int freeSpinsLeft;
    private final boolean freeSpinsTriggered;
    private final long updatedBalance;
    private final List<String> lineWins;
    private final String specialSymbol;
    private final List<Integer> expandingRows;

    public SpinResult(List<List<String>> reels, Set<String> winningPositions, int winAmount,
                      int freeSpinsLeft, boolean freeSpinsTriggered, long updatedBalance,
                      List<String> lineWins, String specialSymbol, List<Integer> expandingRows) {
        this.reels = reels;
        this.winningPositions = winningPositions;
        this.winAmount = winAmount;
        this.freeSpinsLeft = freeSpinsLeft;
        this.freeSpinsTriggered = freeSpinsTriggered;
        this.updatedBalance = updatedBalance;
        this.lineWins = lineWins;
        this.specialSymbol = specialSymbol;
        this.expandingRows = expandingRows;
    }

    public List<List<String>> getReels() { return reels; }
    public Set<String> getWinningPositions() { return winningPositions; }
    public int getWinAmount() { return winAmount; }
    public int getFreeSpinsLeft() { return freeSpinsLeft; }
    public boolean isFreeSpinsTriggered() { return freeSpinsTriggered; }
    public long getUpdatedBalance() { return updatedBalance; }
    public List<String> getLineWins() { return lineWins; }
    public String getSpecialSymbol() { return specialSymbol; }
    public List<Integer> getExpandingRows() { return expandingRows; }
}
