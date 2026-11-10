import 'dart:async';

import 'package:flutter/material.dart';

import '../services/slot_service.dart';
import '../services/user_service.dart';
import '../widgets/reel_widget.dart';

class SlotScreen extends StatefulWidget {
  final SlotService slotService;
  final UserService userService;

  const SlotScreen(
      {super.key, required this.slotService, required this.userService});

  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  bool spinning = false;
  bool isLoadingData = true;
  bool canStopEarly = false;
  bool autoSpinEnabled = false;
  List<bool> reelSpinning = [
    false,
    false,
    false,
    false,
    false,
  ];
  int autoSpinRemaining = 0;
  Completer<void>? _spinAnimationCompleter;

  int? currentUserId;
  String username = "Lade...";
  int balance = 0;
  int bet = 5; // ⭐ Basis-Bet auf 5 Cents gesetzt (für 5 Linien im Backend)
  int lastWin = 0;
  int totalWin = 0; // Anzeige für den addierten Gesamtgewinn
  List<String> detailedLineWins =
      []; // Speichert die einzelnen Liniengewinne (z.B. "L1: +2€")
  int freeSpinsRemaining = 0;
  String?
      specialSymbol; // Speichert das Sondersymbol aus dem Backend-SpinResult

  List<List<String>> currentMatrix = List.generate(5, (_) => <String>[]);
  List<List<int>> highlighted = List.generate(5, (_) => <int>[]);

  @override
  void initState() {
    super.initState();
    _loadInitialUserData();
  }

  Future<void> _loadInitialUserData() async {
    try {
      final profile = await widget.userService.getProfile();
      if (!mounted) return;
      setState(() {
        if (profile != null) {
          currentUserId = profile.id;
          username = profile.username;
          balance = profile.balance ~/ 100; // Umrechnung in Euro
        }
        isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        username = "Ladefehler";
        isLoadingData = false;
      });
    }
  }

  Future<void> _spin() async {
    if (spinning || isLoadingData || currentUserId == null) return;

    if (balance < bet && freeSpinsRemaining <= 0) {
      if (autoSpinEnabled) {
        _stopAutoSpin();
      }
      return;
    }

    setState(() {
      spinning = true;

      reelSpinning = [
        true,
        true,
        true,
        true,
        true,
      ];

      canStopEarly = false;
      highlighted = List.generate(5, (_) => <int>[]);
      detailedLineWins = [];
      totalWin = 0;
    });

    try {
      final result = await widget.slotService.spin(currentUserId!, bet);

      if (result != null) {
        setState(() {
          // Kopie erstellen, damit wir die Matrix später verändern können
          currentMatrix = result.reels
              .map((reel) => List<String>.from(reel))
              .toList();

          canStopEarly = true;
        });

        _spinAnimationCompleter = Completer<void>();
        _runCascadeTimer();

        await _spinAnimationCompleter!.future;

        if (!mounted) return;

        // Gewinnpositionen markieren
        setState(() {
          List<List<int>> newHighlights =
          List.generate(5, (_) => <int>[]);

          for (var position in result.winningPositions) {
            final parts = position.split(',');

            if (parts.length == 2) {
              int reelIdx = int.parse(parts[0]);
              int rowIdx = int.parse(parts[1]);

              if (reelIdx >= 0 &&
                  reelIdx < 5 &&
                  rowIdx >= 0 &&
                  rowIdx < 3) {
                newHighlights[reelIdx].add(rowIdx);
              }
            }
          }

          highlighted = newHighlights;
        });

        // =====================================================
        // SPECIAL SYMBOL EXPANSION ANIMATION
        // =====================================================

        if (result.expandingRows.isNotEmpty &&
            result.specialSymbol != null) {

          await Future.delayed(
            const Duration(milliseconds: 500),
          );

          for (final row in result.expandingRows) {

            for (int reel = 0; reel < 5; reel++) {

              if (!mounted) return;

              setState(() {
                currentMatrix[reel][row] =
                result.specialSymbol!;
              });

              await Future.delayed(
                const Duration(milliseconds: 150),
              );
            }
          }
        }

        // =====================================================
        // FREISPIEL POPUP
        // =====================================================

        if (result.freeSpinsTriggered &&
            freeSpinsRemaining == 0) {

          final originalHighlights =
          List<List<int>>.from(
            highlighted.map(
                  (x) => List<int>.from(x),
            ),
          );

          for (int i = 0; i < 3; i++) {

            await Future.delayed(
              const Duration(milliseconds: 250),
            );

            if (!mounted) return;

            setState(() {
              highlighted =
                  List.generate(5, (_) => <int>[]);
            });

            await Future.delayed(
              const Duration(milliseconds: 250),
            );

            if (!mounted) return;

            setState(() {
              highlighted = originalHighlights;
            });
          }

          final chosenSymbol =
          await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (_) => SpecialSymbolDialog(
              targetSymbol:
              result.specialSymbol ??
                  "EXPLORER",
            ),
          );

          if (mounted && chosenSymbol != null) {
            setState(() {
              specialSymbol = chosenSymbol;
            });
          }
        }

        // =====================================================
        // ERGEBNISSE ÜBERNEHMEN
        // =====================================================

        setState(() {
          balance = result.updatedBalance ~/ 100;
          lastWin = result.winAmount ~/ 100;
          freeSpinsRemaining = result.freeSpinsLeft;
          totalWin = result.winAmount ~/ 100;

          if (result.specialSymbol != null) {
            specialSymbol = result.specialSymbol;
          }

          if (totalWin > 0 &&
              result.lineWins.isNotEmpty) {
            detailedLineWins =
            List<String>.from(result.lineWins);
          } else if (totalWin > 0) {
            detailedLineWins = [
              "Gewinn: +$totalWin €"
            ];
          } else {
            detailedLineWins = [];
          }

          if (freeSpinsRemaining == 0) {
            specialSymbol = null;
          }
        });
      }
    } catch (e) {
      print("Fehler im Ablauf: $e");
    } finally {
      if (mounted) {
        setState(() {
          spinning = false;
          canStopEarly = false;

          if (autoSpinEnabled &&
              balance < bet &&
              freeSpinsRemaining <= 0) {
            autoSpinEnabled = false;
            autoSpinRemaining = 0;
          }
        });
      }
    }
  }

  void _startAutoSpin([int count = 50]) {
    if (spinning) return;

    setState(() {
      autoSpinEnabled = true;
      autoSpinRemaining = count;
    });

    _runAutoSpin();
  }

  void _stopAutoSpin() {
    setState(() {
      autoSpinEnabled = false;
      autoSpinRemaining = 0;
    });
  }

  Future<void> _runAutoSpin() async {
    while (mounted &&
        autoSpinEnabled &&
        autoSpinRemaining > 0 &&
        (balance >= bet || freeSpinsRemaining > 0)) {
      await _spin();

      if (!mounted) return;

      setState(() {
        autoSpinRemaining--;
      });

      await Future.delayed(
        const Duration(milliseconds: 300),
      );
    }

    if (mounted) {
      setState(() {
        autoSpinEnabled = false;
        autoSpinRemaining = 0;
      });
    }
  }

  void _runCascadeTimer() async {

    for (int i = 0; i < 5; i++) {

      await Future.delayed(
        const Duration(milliseconds: 350),
      );

      if (!mounted) return;

      setState(() {
        reelSpinning[i] = false;
      });
    }

    _stopSpinVisualsDirectly();
  }

  void _stopSpinVisualsDirectly() {

    if (mounted) {
      setState(() {

        reelSpinning = [
          false,
          false,
          false,
          false,
          false,
        ];
      });
    }

    if (_spinAnimationCompleter != null &&
        !_spinAnimationCompleter!.isCompleted) {
      _spinAnimationCompleter!.complete();
    }
  }

  void increaseBet() => setState(() => bet = (bet == 5) ? 10 : (bet + 5));

  void decreaseBet() => setState(() {
        if (bet > 5) bet -= 5;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/img.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: buildReels(),
                      ),
                    ],
                  ),
                ),
              ),
          Container(
            width: 750,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // LINKS
                Expanded(
                  flex: 4,
                  child: buildHeaderLayout(),
                ),

                // MITTE
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [

                      Text(
                        detailedLineWins.isNotEmpty
                            ? detailedLineWins.first
                            : "Keine Linie",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "FS: $freeSpinsRemaining",
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Auto: $autoSpinRemaining",
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                // RECHTS
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      buildBetControls(),

                      const SizedBox(height: 8),

                      buildSpinButton(),

                      const SizedBox(height: 8),

                      buildAutoSpinButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeaderLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Welcome $username",
            style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("Balance: $balance €",
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 4),
        Text("Last Win: $lastWin €",
            style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text("Total Win: ",
                style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text("$totalWin €",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        if (detailedLineWins.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              detailedLineWins.join(" | "),
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget buildBetControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("BET",
            style: TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: spinning ? null : decreaseBet,
              icon: const Icon(Icons.remove_circle,
                  color: Colors.white, size: 28),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text("$bet C",
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: spinning ? null : increaseBet,
              icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSpinButton() {
    return SizedBox(
      width: 140,
      height: 45,
      child: !spinning
          ? ElevatedButton.icon(
              onPressed: isLoadingData || currentUserId == null ? null : _spin,
              icon: const Icon(Icons.casino),
              label: const Text("SPIN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          : ElevatedButton.icon(
              onPressed: canStopEarly ? _stopSpinVisualsDirectly : null,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              icon: const Icon(Icons.stop),
              label: const Text("STOP",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
    );
  }

  Widget buildAutoSpinButton() {
    return SizedBox(
      width: 140,
      height: 45,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: autoSpinEnabled ? Colors.redAccent : Colors.green,
        ),
        onPressed: autoSpinEnabled ? _stopAutoSpin : () => _startAutoSpin(50),
        icon: Icon(
          autoSpinEnabled ? Icons.stop_circle : Icons.autorenew,
        ),
        label: Text(
          autoSpinEnabled ? "AUTO STOP" : "AUTO x50",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildReels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return ReelWidget(
          reelIndex: i,
          spinning: reelSpinning[i],
          highlightedRows: highlighted[i],
          serverSymbols: currentMatrix.length > i ? currentMatrix[i] : [],
        );
      }),
    );
  }
}

// ⭐ HIER IST DIE RADIKALE KORREKTUR:
// Die Variable wird nun direkt beim Erzeugen an die State-Klasse übergeben.
// Dadurch entfällt der fehleranfällige "widget."-Aufruf komplett!
class SpecialSymbolDialog extends StatefulWidget {
  final String targetSymbol;

  const SpecialSymbolDialog({super.key, required this.targetSymbol});

  @override
  State createState() => _SpecialSymbolDialogState(targetSymbol);
}

class _SpecialSymbolDialogState extends State {
  final String _resolvedTargetSymbol; // Lokale, sichere Speicherung
  _SpecialSymbolDialogState(this._resolvedTargetSymbol);

  final List symbols = [
    "EXPLORER",
    "PHARAOH",
    "SCARAB",
    "STATUE",
    "A",
    "K",
    "Q",
    "J",
    "TEN"
  ];
  String currentDisplaySymbol = "EXPLORER";
  Timer? _timer;
  bool isSpinning = true;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _startScrollAnimation();
  }

  void _startScrollAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      setState(() {
        currentDisplaySymbol = symbols[_counter % symbols.length];
        _counter++;
      });
      if (_counter > 30) {
        _stopAtTarget();
      }
    });
  }

  void _stopAtTarget() {
    if (!isSpinning) return;
    _timer?.cancel();
    setState(() {
      currentDisplaySymbol =
          _resolvedTargetSymbol; // Nutzt die absolut sichere lokale Variable
      isSpinning = false;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop(_resolvedTargetSymbol);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF4E7C4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8B5A2B), width: 5),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 15)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "3 SCATTER GETROFFEN!",
              style: TextStyle(
                  color: Colors.brown,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif'),
            ),
            const SizedBox(height: 6),
            const Text(
              "Das Buch wählt dein Sondersymbol...",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            Container(
              width: 140,
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                border: Border.all(color: Colors.brown, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentDisplaySymbol,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                    letterSpacing: 1.1),
              ),
            ),
            const SizedBox(height: 24),
            if (isSpinning)
              SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  onPressed: _stopAtTarget,
                  child: const Text("STOP",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
