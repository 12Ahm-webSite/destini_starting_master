import 'package:flutter/services.dart' show rootBundle;
import '../models/story.dart';
import '../models/game_state.dart';

/// Represents all story-related state consumed by the UI.
class StoryState {
  final List<Story> stories;
  final int currentIndex;
  final bool isLoaded;

  const StoryState({
    this.stories = const [],
    this.currentIndex = 0,
    this.isLoaded = false,
  });

  Story get currentStory => stories[currentIndex];

  StoryState copyWith({
    List<Story>? stories,
    int? currentIndex,
    bool? isLoaded,
  }) {
    return StoryState(
      stories: stories ?? this.stories,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

/// Manages story progression logic.
class StoryBrain {
  final GameState gameState;
  StoryState _state;

  // Endings that trigger haptic feedback (scary endings)
  static const Set<int> scaryEndings = {4, 6, 8, 11};
  // All ending indices
  static const Set<int> allEndingIndices = {4, 6, 8, 11, 12, 13, 14};

  StoryBrain({required this.gameState})
      : _state = const StoryState();

  StoryState get state => _state;

  int get currentStoryNumber => _state.currentIndex;

  bool get playerHasBeenToIllusion => gameState.getHasBeenToIllusion();

  // ── Loading ──────────────────────────────────────────────────────────────

  Future<void> loadStories(String locale) async {
    final assetPath = locale == 'en'
        ? 'assets/data/story_data_en.json'
        : 'assets/data/story_data_ar.json';
    final jsonString = await rootBundle.loadString(assetPath);
    final stories = Story.listFromJson(jsonString);
    _state = _state.copyWith(stories: stories, currentIndex: 0, isLoaded: true);
  }

  /// For testing only: inject stories directly.
  void loadTestStories(List<Story> stories) {
    _state = _state.copyWith(stories: stories, currentIndex: 0, isLoaded: true);
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  String getStory() => _state.stories[_state.currentIndex].storyTitle;
  String getChoice1() => _state.stories[_state.currentIndex].choice1;
  String getChoice2() => _state.stories[_state.currentIndex].choice2;

  bool isAtEnding() => allEndingIndices.contains(_state.currentIndex);
  bool isAtScaryEnding() => scaryEndings.contains(_state.currentIndex);

  bool buttonShouldBeVisible() {
    return [0, 1, 2, 3, 5, 7, 9, 10].contains(_state.currentIndex);
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  /// Returns the new ending index if we just arrived at an ending, or null.
  int? nextStory(int choiceNumber) {
    int? reachedEnding;
    final current = _state.currentIndex;

    int next = current;

    switch (current) {
      case 0:
        next = (choiceNumber == 1) ? 1 : 2;
        break;
      case 1:
        next = (choiceNumber == 1) ? 4 : 3;
        break;
      case 2:
        next = (choiceNumber == 1) ? 5 : 6;
        break;
      case 3:
        next = (choiceNumber == 1) ? 5 : 6;
        break;
      case 5:
        next = (choiceNumber == 1) ? 7 : 6;
        break;
      case 7:
        next = (choiceNumber == 1) ? 8 : 9;
        break;
      case 9:
        next = (choiceNumber == 1) ? 10 : 12;
        break;
      case 10:
        if (choiceNumber == 1) {
          next = playerHasBeenToIllusion ? 14 : 12;
        } else {
          next = 11;
        }
        break;
      case 12:
        gameState.setHasBeenToIllusion(true);
        next = 13;
        break;
      case 13:
        gameState.incrementPlays();
        next = 0;
        break;
      case 14:
        gameState.setHasBeenToIllusion(false);
        gameState.incrementPlays();
        next = 0;
        break;
      case 4:
      case 6:
      case 8:
      case 11:
        gameState.incrementPlays();
        next = 0;
        break;
    }

    _state = _state.copyWith(currentIndex: next);

    // Check if we arrived at an ending
    if (allEndingIndices.contains(next)) {
      reachedEnding = next;
      if ([4, 6, 8, 11, 13, 14].contains(next)) {
        gameState.addDiscoveredEnding(next);
      }
    }

    return reachedEnding;
  }

  void restart() {
    _state = _state.copyWith(currentIndex: 0);
  }
}
