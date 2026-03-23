import 'dart:math';
import 'package:flutter/material.dart';

/// A floating fog/particle effect for the horror atmosphere.
class FogEffect extends StatefulWidget {
  final int particleCount;
  const FogEffect({super.key, this.particleCount = 30});

  @override
  State<FogEffect> createState() => _FogEffectState();
}

class _FogEffectState extends State<FogEffect> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_FogParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (_) => _FogParticle.random(_random),
    );

    _controller.addListener(() {
      setState(() {
        for (var p in _particles) {
          p.update();
          if (p.x > 1.2 || p.opacity <= 0) {
            p.reset(_random);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _FogPainter(_particles),
        size: Size.infinite,
      ),
    );
  }
}

class _FogParticle {
  double x, y, radius, speed, opacity;

  _FogParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });

  factory _FogParticle.random(Random random) {
    return _FogParticle(
      x: random.nextDouble() * 1.2 - 0.1,
      y: random.nextDouble(),
      radius: random.nextDouble() * 80 + 30,
      speed: random.nextDouble() * 0.0008 + 0.0002,
      opacity: random.nextDouble() * 0.15 + 0.03,
    );
  }

  void update() {
    x += speed;
    opacity -= 0.00005;
  }

  void reset(Random random) {
    x = -0.1;
    y = random.nextDouble();
    radius = random.nextDouble() * 80 + 30;
    speed = random.nextDouble() * 0.0008 + 0.0002;
    opacity = random.nextDouble() * 0.15 + 0.03;
  }
}

class _FogPainter extends CustomPainter {
  final List<_FogParticle> particles;
  _FogPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(p.opacity.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.6);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
