import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_brain.dart';
import 'splash_screen.dart';
import 'fog_effect.dart';

void main() => runApp(Destini());

class Destini extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.cairoTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const AppNavigator(),
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

/// Controls navigation between splash and story screens.
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showSplash = true;

  void _startGame() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showSplash
          ? SplashScreen(key: const ValueKey('splash'), onStart: _startGame)
          : StoryPage(key: const ValueKey('story')),
    );
  }
}

class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with TickerProviderStateMixin {
  final StoryBrain storyBrain = StoryBrain();
  final AudioPlayer player = AudioPlayer();

  late AnimationController _textFadeController;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

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
    ).animate(
      CurvedAnimation(
        parent: _textFadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textFadeController.forward();

    // تشغيل الصوت تلقائياً عند بدء الصفحة
    playBackgroundSound();
  }

  Future<void> playBackgroundSound() async {
    try {
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('sounds/creepy.mp3'));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void updateStory(int choiceNumber) {
    _textFadeController.reverse().then((_) {
      setState(() {
        storyBrain.nextStory(choiceNumber);
      });
      _textFadeController.forward();
    });
  }

  @override
  void dispose() {
    player.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/background.png',
            fit: BoxFit.cover,
          ),

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
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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