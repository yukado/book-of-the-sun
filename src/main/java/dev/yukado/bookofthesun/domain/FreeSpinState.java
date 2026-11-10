package dev.yukado.bookofthesun.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "free_spins")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FreeSpinState {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(nullable = false)
    private int remainingFreeSpins;
}
