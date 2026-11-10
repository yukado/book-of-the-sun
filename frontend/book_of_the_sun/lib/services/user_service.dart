import 'dart:convert';
import '../core/api_client.dart';
import '../models/user.dart'; // Dein angepasstes User Modell

class UserService {
  final ApiClient api;

  UserService(this.api);

  Future<User?> getProfile() async {
    try {
      // 1. Profildaten laden (ID und E-Mail)
      final profileResponse = await api.get('/user/me');

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body) as Map<String, dynamic>;
        final userId = (profileData['id'] as num).toInt();

        // 2. Kontostand laden aus dem BalanceController
        final balanceResponse = await api.get('/balance/$userId');
        int balanceInCents = 0;

        if (balanceResponse.statusCode == 200) {
          final balanceData = jsonDecode(balanceResponse.body) as Map<String, dynamic>;
          // Holt 'amountInCents' aus deiner Java-Balance-Klasse
          balanceInCents = (balanceData['amountInCents'] as num?)?.toInt() ?? 0;
        }

        // 3. Übergabe an das angepasste User-Modell
        return User.fromJson(profileData, balanceInCents: balanceInCents);
      }

      return null;
    } catch (e) {
      print("Fehler beim Laden des Profils: $e");
      return null;
    }
  }
}
