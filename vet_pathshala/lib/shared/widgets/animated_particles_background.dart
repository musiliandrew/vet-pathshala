import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/unified_theme.dart';

class AnimatedParticlesBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color particleColor;

  const AnimatedParticlesBackground({
    super.key,
    required this.child,
    this.particleCount = 15,
    this.particleColor = UnifiedTheme.primary,
  });

  @override
  State<AnimatedParticlesBackground> createState() => _AnimatedParticlesBackgroundState();
}

class _AnimatedParticlesBackgroundState extends State<AnimatedParticlesBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    _controllers = [];
    _animations = [];
    _particles = [];

    for (int i = 0; i < widget.particleCount; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 10 + math.Random().nextInt(10)),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));

      final particle = Particle(
        size: 50.0 + math.Random().nextDouble() * 100.0,
        startX: math.Random().nextDouble(),
        opacity: 0.05 + math.Random().nextDouble() * 0.05,
        delay: math.Random().nextInt(5),
      );

      _controllers.add(controller);
      _animations.add(animation);
      _particles.add(particle);

      // Start animation with delay
      Future.delayed(Duration(seconds: particle.delay), () {
        if (mounted) {
          controller.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Particles
        Positioned.fill(
          child: CustomPaint(
            painter: ParticlesPainter(
              animations: _animations,
              particles: _particles,
              color: widget.particleColor,
            ),
          ),
        ),
        // Child content
        widget.child,
      ],
    );
  }
}

class Particle {
  final double size;
  final double startX;
  final double opacity;
  final int delay;

  Particle({
    required this.size,
    required this.startX,
    required this.opacity,
    required this.delay,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<Animation<double>> animations;
  final List<Particle> particles;
  final Color color;

  ParticlesPainter({
    required this.animations,
    required this.particles,
    required this.color,
  }) : super(repaint: Listenable.merge(animations));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final animation = animations[i];
      
      if (animation.value == 0.0) continue;

      final progress = animation.value;
      final x = particle.startX * size.width;
      final y = size.height - (progress * (size.height + particle.size));
      
      // Fade in and out
      double opacity = particle.opacity;
      if (progress < 0.1) {
        opacity *= progress / 0.1;
      } else if (progress > 0.9) {
        opacity *= (1.0 - progress) / 0.1;
      }

      paint.color = color.withOpacity(opacity);

      canvas.drawCircle(
        Offset(x, y),
        particle.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}