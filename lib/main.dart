import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_brain.dart';
import 'splash_screen.dart';
import 'fog_effect.dart';
import 'game_state.dart';
import 'achievements_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final gameState = GameState();
  await gameState.init();
  runApp(Destini(gameState: gameState));
}

class Destini extends StatelessWidget {
  final GameState gameState;
  const Destini({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.cairoTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: AppNavigator(gameState: gameState),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

class AppNavigator extends StatefulWidget {
  final GameState gameState;
  const AppNavigator({super.key, required this.gameState});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showSplash = true;

  void _startGame() {
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showSplash
          ? SplashScreen(
              key: const ValueKey('splash'),
              onStart: _startGame,
              gameState: widget.gameState,
            )
          : StoryPage(
              key: const ValueKey('story'),
              gameState: widget.gameState,
            ),
    );
  }
}

class StoryPage extends StatefulWidget {
  final GameState gameState;
  const StoryPage({super.key, required this.gameState});

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with TickerProviderStateMixin {
  late StoryBrain storyBrain;
  final AudioPlayer bgPlayer = AudioPlayer();
  final AudioPlayer sfxPlayer = AudioPlayer();

  late AnimationController _textFadeController;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  // For the new-ending popup
  bool _showEndingBanner = false;
  String _endingBannerText = '';

  @override
  void initState() {
    super.initState();
    storyBrain = StoryBrain(gameState: widget.gameState);

    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textFade = CurvedAnimation(
      parent: _textFadeController,
      curve: Curves.easeIn,
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textFadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textFadeController.forward();
    _playBackgroundSound();
  }

  Future<void> _playBackgroundSound() async {
    try {
      await bgPlayer.setReleaseMode(ReleaseMode.loop);
      await bgPlayer.play(AssetSource('sounds/creepy.mp3'));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _playChoiceSound() {
    // Light haptic on every choice
    HapticFeedback.lightImpact();
  }

  void _triggerScaryEnding() {
    // Heavy haptic pattern for scary endings
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.heavyImpact();
    });
  }

  void _triggerTrueEnding() {
    // Medium haptic for the true ending
    HapticFeedback.mediumImpact();
  }

  void _showNewEndingDiscovered(int endingIndex) {
    final info = GameState.endingDetails[endingIndex];
    if (info == null) return;

    setState(() {
      _showEndingBanner = true;
      _endingBannerText = '${info.icon} نهاية جديدة: ${info.title}';
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showEndingBanner = false);
      }
    });
  }

  void updateStory(int choiceNumber) {
    _playChoiceSound();

    _textFadeController.reverse().then((_) {
      final wasAlreadyDiscovered =
          widget.gameState.getDiscoveredEndings().contains(
                _getNextEndingIndex(choiceNumber),
              );

      setState(() {
        final reachedEnding = storyBrain.nextStory(choiceNumber);

        if (reachedEnding != null) {
          // Haptic feedback based on ending type
          if (StoryBrain.scaryEndings.contains(reachedEnding)) {
            _triggerScaryEnding();
          } else if (reachedEnding == 14) {
            _triggerTrueEnding();
          }

          // Show banner if this is a newly discovered ending
          if (!wasAlreadyDiscovered &&
              [4, 6, 8, 11, 13, 14].contains(reachedEnding)) {
            _showNewEndingDiscovered(reachedEnding);
          }
        }
      });

      _textFadeController.forward();
    });
  }

  // Helper to predict next ending (for checking "was already discovered")
  int? _getNextEndingIndex(int choiceNumber) {
    // This is a simplified prediction based on current story number
    final current = storyBrain.currentStoryNumber;
    switch (current) {
      case 1:
        return choiceNumber == 1 ? 4 : null;
      case 2:
        return choiceNumber == 2 ? 6 : null;
      case 3:
        return choiceNumber == 2 ? 6 : null;
      case 5:
        return choiceNumber == 2 ? 6 : null;
      case 7:
        return choiceNumber == 1 ? 8 : null;
      case 10:
        return choiceNumber == 2 ? 11 : null;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    bgPlayer.dispose();
    sfxPlayer.dispose();
    _textFadeController.dispose();
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),

          const FogEffect(particleCount: 20),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 40.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Achievements button + ending counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ending counter badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          '📖 ${widget.gameState.discoveredCount}/${widget.gameState.totalEndings}',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      // Achievements button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AchievementsScreen(
                                gameState: widget.gameState,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.amber.withOpacity(0.1),
                            border: Border.all(
                                color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Text(
                            '🏆 ${widget.gameState.unlockedAchievementCount}/${widget.gameState.totalAchievements}',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.amber.shade200,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    flex: 12,
                    child: Center(
                      child: SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withOpacity(0.3),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Text(
                              storyBrain.getStory(),
                              style: GoogleFonts.cairo(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500,
                                height: 1.8,
                                color: Colors.white.withOpacity(0.95),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildChoiceButton(
                    text: storyBrain.getChoice1(),
                    onPressed: () => updateStory(1),
                    gradientColors: [
                      const Color(0xFFB71C1C),
                      const Color(0xFF880E4F),
                    ],
                    shadowColor: Colors.red,
                  ),

                  const SizedBox(height: 16),

                  if (storyBrain.buttonShouldBeVisible())
                    _buildChoiceButton(
                      text: storyBrain.getChoice2(),
                      onPressed: () => updateStory(2),
                      gradientColors: [
                        const Color(0xFF1A237E),
                        const Color(0xFF4A148C),
                      ],
                      shadowColor: Colors.blue,
                    ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // New ending discovered banner
          if (_showEndingBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: AnimatedOpacity(
                  opacity: _showEndingBanner ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.2),
                          Colors.red.withOpacity(0.2),
                        ],
                      ),
                      border:
                          Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Text(
                      _endingBannerText,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade200,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String text,
    required VoidCallback onPressed,
    required List<Color> gradientColors,
    required Color shadowColor,
  }) {
    return FadeTransition(
      opacity: _textFade,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}