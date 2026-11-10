import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class BookScrollDialog extends StatefulWidget {
  final String targetSymbol;

  const BookScrollDialog({super.key, required this.targetSymbol});

  @override
  State<BookScrollDialog> createState() => _BookScrollDialogState();
}

class _BookScrollDialogState extends State<BookScrollDialog> {
  String currentSymbol = "A";
  bool isChoosing = true;
  Timer? timer;

  // Alle wählbaren Sondersymbole (ohne das Buch selbst)
  final List<String> symbols = [
    "EXPLORER", "PHARAOH", "SCARAB", "STATUE", "A", "K", "Q", "J", "TEN"
  ];

  @override
  void initState() {
    super.initState();
    _startScrollAnimation();
  }

  void _startScrollAnimation() {
    int ticks = 0;
    final Random rand = Random();

    // Startet das schnelle Durchrotieren (alle 80 Millisekunden ein neues Symbol)
    timer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      setState(() {
        currentSymbol = symbols[rand.nextInt(symbols.length)];
      });
      ticks++;

      // Nach ca. 2.5 Sekunden (30 Ticks) stoppen wir punktgenau auf dem Server-Symbol
      if (ticks > 30) {
        timer?.cancel();
        setState(() {
          currentSymbol = widget.targetSymbol.toUpperCase();
          isChoosing = false;
        });

        // Das ausgewählte Symbol bleibt für 2.5 Sekunden stehen, dann schließt sich der Dialog automatisch
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _getAssetPath(String symbolKey) {
    return "assets/symbols/${symbolKey.toLowerCase()}.png";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            // Altes, mystisches Ägypten-Pergamentbraun mit Goldrand
            color: const Color(0xFF2D1B05),
            border: Border.all(color: Colors.amber, width: 3.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 3,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "FREE SPINS WON",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isChoosing ? "Wähle Spezial-Symbol..." : "Spezial-Symbol gewählt!",
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 25),

              // Das rotierende/ausgewählte Symbolfeld
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ⭐ HIER KORRIGIERT:
                  color: isChoosing ? Colors.black.withOpacity(0.35) : Colors.amber.withOpacity(0.15),
                  border: Border.all(
                    color: isChoosing ? Colors.amber.withOpacity(0.5) : Colors.amberAccent,
                    width: isChoosing ? 2 : 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isChoosing
                      ? []
                      : [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
                ),
                child: Image.asset(
                  _getAssetPath(currentSymbol),
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),
              if (!isChoosing) ...[
                const Text(
                  "10 FREISPIELE STARTEN",
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
