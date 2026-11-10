package dev.yukado.bookofthesun.domain;

import java.util.List;

public class SymbolSet {


    public static final Symbol SPECIAL = Symbol.BOOK;

    public static final List<Symbol> ALL = List.of(
            Symbol.A, Symbol.K, Symbol.Q, Symbol.J, Symbol.TEN,
            Symbol.SCARAB, Symbol.PHARAOH, Symbol.EXPLORER, Symbol.STATUE,
            Symbol.BOOK
    );
}
