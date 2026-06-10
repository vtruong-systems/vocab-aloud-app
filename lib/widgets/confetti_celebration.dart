import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

const kConfettiAutoAdvanceDelay = Duration(milliseconds: 1200);

class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConfettiCelebrationState createState() => ConfettiCelebrationState();
}

class ConfettiCelebrationState extends State<ConfettiCelebration> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void trigger() {
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirection: pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.08,
            numberOfParticles: 18,
            maxBlastForce: 18,
            minBlastForce: 8,
            gravity: 0.15,
            shouldLoop: false,
            colors: const [
              Colors.amber,
              Colors.lightBlue,
              Colors.green,
              Colors.purple,
              Colors.orange,
            ],
          ),
        ),
      ],
    );
  }
}
