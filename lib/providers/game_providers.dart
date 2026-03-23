import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../controllers/story_brain.dart';

// ── GameState Provider ─────────────────────────────────────────────────────

final gameStateProvider = Provider<GameState>((ref) {
  // GameState is initialized in main() and passed via ProviderScope overrides.
  throw UnimplementedError('gameStateProvider must be overridden in main()');
});

// ── Locale Provider ────────────────────────────────────────────────────────

final localeProvider = StateProvider<Locale>((ref) => const Locale('ar'));

// ── StoryBrain Provider ────────────────────────────────────────────────────

final storyBrainProvider =
    StateNotifierProvider<StoryBrainNotifier, StoryState>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return StoryBrainNotifier(gameState: gameState);
});

/// A StateNotifier wrapper around StoryBrain for use with Riverpod.
class StoryBrainNotifier extends StateNotifier<StoryState> {
  final StoryBrain _brain;

  StoryBrainNotifier({required GameState gameState})
      : _brain = StoryBrain(gameState: gameState),
        super(const StoryState());

  StoryBrain get brain => _brain;

  Future<void> loadStories(String locale) async {
    await _brain.loadStories(locale);
    state = _brain.state;
  }

  int? nextStory(int choiceNumber) {
    final result = _brain.nextStory(choiceNumber);
    state = _brain.state;
    return result;
  }

  void restart() {
    _brain.restart();
    state = _brain.state;
  }

  bool buttonShouldBeVisible() => _brain.buttonShouldBeVisible();
  bool isAtEnding() => _brain.isAtEnding();
  bool isAtScaryEnding() => _brain.isAtScaryEnding();
  String getStory() => _brain.getStory();
  String getChoice1() => _brain.getChoice1();
  String getChoice2() => _brain.getChoice2();
  int get currentStoryNumber => _brain.currentStoryNumber;

  static const Set<int> scaryEndings = StoryBrain.scaryEndings;
}
