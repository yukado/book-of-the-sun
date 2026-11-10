package dev.yukado.bookofthesun.service;

import dev.yukado.bookofthesun.domain.Symbol;
import dev.yukado.bookofthesun.domain.SymbolSet;
import org.springframework.stereotype.Service;

import java.util.Random;

@Service
public class RNGService {

    private final Random random = new Random();

    public Symbol[][] spinReels() {

        int reels = 5;
        int rows = 3;

        Symbol[][] result = new Symbol[reels][rows];

        for (int reel = 0; reel < reels; reel++) {
            for (int row = 0; row < rows; row++) {
                result[reel][row] =
                        SymbolSet.ALL.get(
                                random.nextInt(SymbolSet.ALL.size())
                        );
            }
        }

        return result;
    }
}