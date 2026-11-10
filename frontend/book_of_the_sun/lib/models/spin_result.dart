class SpinResult {
  final List<List<String>> reels;
  final List<String> winningPositions;
  final int winAmount;
  final int freeSpinsLeft;
  final bool freeSpinsTriggered;
  final int updatedBalance;
  final List<String> lineWins;
  final String? specialSymbol;
  final List<int> expandingRows;

  SpinResult({
    required this.reels,
    required this.winningPositions,
    required this.winAmount,
    required this.freeSpinsLeft,
    required this.freeSpinsTriggered,
    required this.updatedBalance,
    required this.lineWins,
    this.specialSymbol,
    required this.expandingRows,
  });

  factory SpinResult.fromJson(Map<String, dynamic> json) {
    return SpinResult(
      // Mappt 'matrix' aus dem DTO auf 'reels' (falls dein Backend 'matrix' sendet, sonst 'reels' nutzen)
      reels: List<List<String>>.from(
          (json['reels'] ?? json['matrix']).map((x) => List<String>.from(x))
      ),
      winningPositions: List<String>.from(json['winningPositions'] ?? []),
      // Fängt Unterschiede zwischen winAmount und winAmountInCents ab
      winAmount: json['winAmount'] ?? json['winAmountInCents'] ?? 0,
      // Fängt Unterschiede zwischen freeSpinsLeft und freeSpinsWon ab
      freeSpinsLeft: json['freeSpinsLeft'] ?? json['freeSpinsWon'] ?? 0,
      freeSpinsTriggered: json['freeSpinsTriggered'] ?? false,
      // Fängt Unterschiede zwischen updatedBalance und currentBalanceInCents ab
      updatedBalance: json['updatedBalance'] ?? json['currentBalanceInCents'] ?? 0,
      // Verhindert Abstürze, falls lineWins mal null oder leer ist
      lineWins: json['lineWins'] != null
          ? List<String>.from(json['lineWins'])
          : <String>[],
      // ⭐ NEU: Mappt das 'expandingSymbol' aus dem Spring-DTO auf dein specialSymbol
      specialSymbol: json['expandingSymbol'] ?? json['specialSymbol'],
      expandingRows: (json['expandingRows'] as List?)
          ?.map((e) => e as int)
          .toList() ??
          [],
    );
  }
}