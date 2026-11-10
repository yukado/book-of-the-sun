import 'dart:math';
import 'package:flutter/material.dart';
import '../slot/slot_constants.dart';

class ReelWidget extends StatefulWidget {
  final int reelIndex;
  final bool spinning;
  final List<int> highlightedRows;
  final List<String> serverSymbols;

  const ReelWidget({
    super.key,
    required this.reelIndex,
    required this.spinning,
    required this.highlightedRows,
    required this.serverSymbols,
  });

  @override
  State<ReelWidget> createState() => _ReelWidgetState();
}

class _ReelWidgetState extends State<ReelWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  double offset = 0.0;
  bool isBlurSpinning = false;
  final List<String> poolSymbols = ["BOOK", "PHARAOH", "SCARAB", "A", "K", "Q", "J", "TEN", "EXPLORER", "STATUE"];

  String _getAssetPath(String symbolKey) {
    return "assets/symbols/${symbolKey.toLowerCase()}.png";
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    controller.addListener(() {
      if (!mounted) return;
      setState(() {
        offset += 55;
        if (offset >= symbolHeight) offset = 0;
      });
    });
  }

  @override
  void didUpdateWidget(covariant ReelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning && !oldWidget.spinning) {
      _startSpin();
    } else if (!widget.spinning && oldWidget.spinning) {
      _stopSpin();
    }
  }

  void _startSpin() {
    if (!mounted) return;
    setState(() { isBlurSpinning = true; });
    controller.repeat();
  }

  void _stopSpin() {
    if (!mounted) return;
    controller.stop();
    setState(() {
      offset = 0.0;
      isBlurSpinning = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Random rand = Random();

    return ClipRect(
      child: SizedBox(
        width: symbolWidth,
        height: symbolHeight * visibleSymbols,
        child: Stack(
          children: [
            Positioned(
              top: offset - symbolHeight,
              child: Column(
                children: List.generate(visibleSymbols + 1, (rowIndex) {
                  String symbolKey;

                  if (isBlurSpinning) {
                    symbolKey = poolSymbols[rand.nextInt(poolSymbols.length)];
                  } else {
                    if (rowIndex == 0) {
                      symbolKey = widget.serverSymbols.isNotEmpty ? widget.serverSymbols.first : poolSymbols[0];
                    } else {
                      int serverIndex = rowIndex - 1;
                      if (widget.serverSymbols.isNotEmpty && serverIndex < widget.serverSymbols.length) {
                        symbolKey = widget.serverSymbols[serverIndex];
                      } else {
                        symbolKey = poolSymbols[rowIndex % poolSymbols.length];
                      }
                    }
                  }

                  int currentVisibleRow = rowIndex - 1;
                  final bool highlighted = !isBlurSpinning && currentVisibleRow >= 0 && widget.highlightedRows.contains(currentVisibleRow);

                  return SizedBox(
                    width: symbolWidth,
                    height: symbolHeight,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: symbolWidth * 0.85,
                        height: symbolHeight * 0.85,
                        decoration: highlighted
                            ? BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          border: Border.all(color: Colors.amberAccent, width: 3),
                          borderRadius: BorderRadius.circular(8),
                        )
                            : const BoxDecoration(),
                        child: Image.asset(_getAssetPath(symbolKey), fit: BoxFit.contain),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
