package dev.yukado.bookofthesun.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity // ⭐ ZWINGEND ERFORDERLICH: Sagt Spring, dass dies ein "managed type" ist
@Table(name = "games") // Definiert den Tabellennamen in der Datenbank
@Getter
@Setter
@NoArgsConstructor // Zwingend erforderlich für JPA/Hibernate
public class Game {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Primärschlüssel für die Datenbank-Tabelle

    @Column(name = "user_id", unique = true, nullable = false)
    private Long userId;

    private double balance;
    private int lastWin;
    private int freeSpins;

    @Column(name = "special_symbol")
    private String specialSymbol;

    // Dein Konstruktor für den SlotService
    public Game(Long userId, long balanceInCents, int lastWinInCents, int freeSpins, String specialSymbol) {
        this.userId = userId;
        this.balance = balanceInCents / 100.0;
        this.lastWin = lastWinInCents / 100;
        this.freeSpins = freeSpins;
        this.specialSymbol = specialSymbol;
    }
}
