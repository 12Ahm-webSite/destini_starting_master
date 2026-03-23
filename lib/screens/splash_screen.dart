import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/fog_effect.dart';
import '../models/game_state.dart';

/// A dark, atmospheric splash screen for the horror story app.
class SplashScreen extends StatefulWidget {
  final VoidCallback onStart;
  final GameState gameState;
  const SplashScreen({super.key, required this.onStart, required this.gameState});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeIn;
  late Animation<double> _titleSlide;
  late Animation<double> _pulse;

  final AudioPlayer _splashPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _playIntroSound();
  }

  Future<void> _playIntroSound() async {
    try {
      await _splashPlayer.setVolume(0.5);
      await _splashPlayer.play(AssetSource('sounds/creepy.mp3'));
    } catch (e) {
      debugPrint("Splash audio error: $e");
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _splashPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('images/background.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),
          const FogEffect(particleCount: 25),
          SafeArea(
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _titleSlide.value),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  Text(
                    'وَهْم',
                    style: GoogleFonts.cairo(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(blurRadius: 30, color: Colors.red.withOpacity(0.6)),
                        Shadow(blurRadius: 60, color: Colors.red.withOpacity(0.3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'قراراتك تصنع مصيرك',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        Colors.red.withOpacity(0.5),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                  const Spacer(flex: 3),
                  ScaleTransition(
                    scale: _pulse,
                    child: GestureDetector(
                      onTap: () {
                        _splashPlayer.stop();
                        widget.onStart();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.red.withOpacity(0.6), width: 1.5),
                          gradient: LinearGradient(colors: [
                            Colors.red.withOpacity(0.15),
                            Colors.red.withOpacity(0.05),
                          ]),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          'ابدأ المغامرة',
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  Text(
                    '⚠️ هل أنت مستعد لمعرفة الحقيقة؟',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  if (widget.gameState.discoveredCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '📖 ${widget.gameState.discoveredCount}/${widget.gameState.totalEndings} نهايات مكتشفة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.amber.withOpacity(0.4),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
