package dev.yukado.bookofthesun.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "balances")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Balance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long amountInCents;

    @Builder.Default
    @Column(nullable = false, columnDefinition = "int default 0")
    private Integer freeSpins = 0; // ⭐ Setzt die 0 als Default-Wert für Lombok-Builder!

    // ⭐ NEU: Speichert das Sondersymbol für die laufenden Freispiele
    @Column(name = "expanding_symbol")
    private String expandingSymbol;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    private User user;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getAmountInCents() {
        return amountInCents;
    }

    public void setAmountInCents(Long amountInCents) {
        this.amountInCents = amountInCents;
    }

    public Integer getFreeSpins() {
        return freeSpins;
    }

    public void setFreeSpins(Integer freeSpins) {
        this.freeSpins = freeSpins;
    }

    public String getExpandingSymbol() {
        return expandingSymbol;
    }

    public void setExpandingSymbol(String expandingSymbol) {
        this.expandingSymbol = expandingSymbol;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
