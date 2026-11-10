import 'dart:convert';
import '../core/api_client.dart';
import '../models/spin_result.dart';

class SlotService {
  final ApiClient api;

  SlotService(this.api);

  Future<SpinResult?> spin(int userId, int betAmountInCents) async {
    try {
      final response = await api.post('/slot/spin', {
        'userId': userId,
        'betAmountInCents': betAmountInCents,
      });

      if (response.statusCode == 200) {
        // ⭐ ROHE SERVER-ANTWORT ERZWUNGEN IN CHROME AUSGEBEN
        print("--- RAW JSON FROM SERVER ---");
        print(response.body);
        print("----------------------------");

        // SICHERHEITS-CHECK: Falls der ApiClient den Body bereits als Map zurückgibt
        Map<String, dynamic> data;
        if (response.body is Map) {
          data = response.body as Map<String, dynamic>;
        } else if (response.body is String) {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } else {
          throw Exception("Unerwarteter Datentyp für response.body: ${response.body.runtimeType}");
        }

        return SpinResult.fromJson(data);
      } else {
        print("Slot-Fehler vom Server (Status ${response.statusCode}): ${response.body}");
        return null;
      }
    } catch (e, stacktrace) {
      print("Crash im SlotService.spin: $e");
      print(stacktrace);
      return null;
    }
  }
}
