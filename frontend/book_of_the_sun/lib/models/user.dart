class User {
  final int id;
  final String username;
  final int balance; // Erweitert für den Kontostand aus dem Backend

  const User({
    required this.id,
    required this.username,
    this.balance = 0, // Standardmäßig 0, falls bei manchen Abfragen keine Balance geliefert wird
  });

  // Passt sich an die Felder deines Backends an (id statt userId, email statt username)
  factory User.fromJson(Map<String, dynamic> json, {int balanceInCents = 0}) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      // Das Backend liefert 'email', wir mappen es im Frontend auf deine Variable 'username'
      username: (json['email'] ?? json['username'] ?? 'Unbekannt') as String,
      balance: balanceInCents,
    );
  }
}
