package dev.yukado.bookofthesun.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SpinResultDto {

    @JsonProperty("matrix")
    private List<List<String>> matrix;

    @JsonProperty("winAmountInCents")
    private int winAmountInCents;

    @JsonProperty("freeSpinsWon")
    private int freeSpinsWon;

    @JsonProperty("expandingSymbol") // Nutzt das Feld, das du bereits vorbereitet hattest
    private String expandingSymbol;

    @JsonProperty("email")
    private String email;

    @JsonProperty("currentBalanceInCents")
    private long currentBalanceInCents;

    @JsonProperty("winningLines")
    private List<int[]> winningLines;

    @JsonProperty("lineWins")
    private List<String> lineWins;

    @JsonProperty("expandingRows")
    private List<Integer> expandingRows;
}
