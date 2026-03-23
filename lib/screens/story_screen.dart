import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';
import '../models/game_state.dart';
import '../widgets/fog_effect.dart';
import 'achievements_screen.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen>
    with TickerProviderStateMixin {
  final AudioPlayer bgPlayer = AudioPlayer();
  final AudioPlayer sfxPlayer = AudioPlayer();

  late AnimationController _textFadeController;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  bool _showEndingBanner = false;
  String _endingBannerText = '';
  bool _loaded = false;

  // قائمة النهايات المخيفة
  final List<int> _scaryEndingsList = [4, 6, 8, 11, 13];

  @override
  void initState() {
    super.initState();
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
    ).animate(CurvedAnimation(
      parent: _textFadeController,
      curve: Curves.easeOutCubic,
    ));
    _textFadeController.forward();
    _playBackgroundSound();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final locale = ref.read(localeProvider).languageCode;
      ref.read(storyBrainProvider.notifier).loadStories(locale);
    }
  }

  Future<void> _playBackgroundSound() async {
    try {
      await bgPlayer.setReleaseMode(ReleaseMode.loop);
      await bgPlayer.play(AssetSource('sounds/creepy.mp3'));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _playChoiceSound() => HapticFeedback.lightImpact();

  void _triggerScaryEnding() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 150),
        () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 300),
        () => HapticFeedback.heavyImpact());
  }

  void _triggerTrueEnding() => HapticFeedback.mediumImpact();

  void _showNewEndingDiscovered(int endingIndex) {
    final info = GameState.endingDetails[endingIndex];
    if (info == null) return;
    final locale = ref.read(localeProvider).languageCode;
    final title = locale == 'en' ? info.titleEn : info.title;
    setState(() {
      _showEndingBanner = true;
      _endingBannerText = '${info.icon} ${locale == 'en' ? 'New Ending: ' : 'نهاية جديدة: '}$title';
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showEndingBanner = false);
    });
  }

  void updateStory(int choiceNumber) {
    _playChoiceSound();
    final notifier = ref.read(storyBrainProvider.notifier);
    final gameState = ref.read(gameStateProvider);

    _textFadeController.reverse().then((_) {
      final wasAlreadyDiscovered =
          gameState.getDiscoveredEndings().contains(_getNextEndingIndex(choiceNumber));

      final reachedEnding = notifier.nextStory(choiceNumber);

      if (reachedEnding != null) {
        // استخدام القائمة المحلية بدلاً من notifier.scaryEndings
        if (_scaryEndingsList.contains(reachedEnding)) {
          _triggerScaryEnding();
        } else if (reachedEnding == 14) {
          _triggerTrueEnding();
        }
        if (!wasAlreadyDiscovered && [4, 6, 8, 11, 13, 14].contains(reachedEnding)) {
          _showNewEndingDiscovered(reachedEnding);
        }
      }
      _textFadeController.forward();
    });
  }

  int? _getNextEndingIndex(int choiceNumber) {
    final notifier = ref.read(storyBrainProvider.notifier);
    final current = notifier.currentStoryNumber;
    switch (current) {
      case 1: return choiceNumber == 1 ? 4 : null;
      case 2: return choiceNumber == 2 ? 6 : null;
      case 3: return choiceNumber == 2 ? 6 : null;
      case 5: return choiceNumber == 2 ? 6 : null;
      case 7: return choiceNumber == 1 ? 8 : null;
      case 10: return choiceNumber == 2 ? 11 : null;
      default: return null;
    }
  }

  void _toggleLocale() {
    final current = ref.read(localeProvider);
    final next = current.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    ref.read(localeProvider.notifier).state = next;
    ref.read(storyBrainProvider.notifier).loadStories(next.languageCode);
    _textFadeController
        .reverse()
        .then((_) => _textFadeController.forward());
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
    final storyState = ref.watch(storyBrainProvider);
    final notifier = ref.read(storyBrainProvider.notifier);
    final gameState = ref.read(gameStateProvider);
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';

    if (!storyState.isLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

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
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar: stats + achievements + locale toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ending counter badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          '📖 ${gameState.discoveredCount}/${gameState.totalEndings}',
                          style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
                        ),
                      ),

                      // Language toggle
                      GestureDetector(
                        onTap: _toggleLocale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue.withOpacity(0.1),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Text(
                            isAr ? '🌐 EN' : '🌐 AR',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.blue.shade200,
                            ),
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
                                gameState: gameState,
                                locale: locale.languageCode,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.amber.withOpacity(0.1),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Text(
                            '🏆 ${gameState.unlockedAchievementCount}/${gameState.totalAchievements}',
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

                  // Story text
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
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Text(
                              notifier.getStory(),
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
                    text: notifier.getChoice1(),
                    onPressed: () => updateStory(1),
                    gradientColors: [const Color(0xFFB71C1C), const Color(0xFF880E4F)],
                    shadowColor: Colors.red,
                  ),

                  const SizedBox(height: 16),

                  if (notifier.buttonShouldBeVisible())
                    _buildChoiceButton(
                      text: notifier.getChoice2(),
                      onPressed: () => updateStory(2),
                      gradientColors: [const Color(0xFF1A237E), const Color(0xFF4A148C)],
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.2),
                          Colors.red.withOpacity(0.2),
                        ],
                      ),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
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
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
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
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
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