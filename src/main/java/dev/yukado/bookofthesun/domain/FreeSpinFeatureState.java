package dev.yukado.bookofthesun.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "free_spin_feature")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FreeSpinFeatureState {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Enumerated(EnumType.STRING)
    private Symbol expandingSymbol;
}
