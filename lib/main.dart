import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/game_state.dart';
import 'providers/game_providers.dart';
import 'screens/splash_screen.dart';
import 'screens/story_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final gameState = GameState();
  await gameState.init();

  runApp(
    ProviderScope(
      overrides: [
        gameStateProvider.overrideWithValue(gameState),
      ],
      child: const DestiniApp(),
    ),
  );
}

class DestiniApp extends ConsumerWidget {
  const DestiniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const AppNavigator(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final isAr = locale.languageCode == 'ar';
        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}

class AppNavigator extends ConsumerStatefulWidget {
  const AppNavigator({super.key});

  @override
  ConsumerState<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends ConsumerState<AppNavigator> {
  bool _showSplash = true;

  void _startGame() {
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.read(gameStateProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showSplash
          ? SplashScreen(
              key: const ValueKey('splash'),
              onStart: _startGame,
              gameState: gameState,
            )
          : const StoryScreen(key: ValueKey('story')),
    );
  }
}