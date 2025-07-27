import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedSpaceBackground extends StatefulWidget {
  const AnimatedSpaceBackground({super.key});

  @override
  State<AnimatedSpaceBackground> createState() => _AnimatedSpaceBackgroundState();
}

class _AnimatedSpaceBackgroundState extends State<AnimatedSpaceBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Offset> _stars = List.generate(150, (_) => Offset(Random().nextDouble(), Random().nextDouble()));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _StarfieldPainter(_stars, _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final List<Offset> stars;
  final double progress;
  final Paint starPaint = Paint()..color = Colors.white.withOpacity(0.8);

  _StarfieldPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final dx = (star.dx * size.width + progress * 100) % size.width;
      final dy = (star.dy * size.height + progress * 50) % size.height;
      canvas.drawCircle(Offset(dx, dy), 1.2, starPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
