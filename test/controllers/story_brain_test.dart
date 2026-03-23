import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:destini_starting_master/controllers/story_brain.dart';
import 'package:destini_starting_master/models/game_state.dart';
import 'package:destini_starting_master/models/story.dart';

// Helper: build a minimal list of stories (15 items) for testing
List<Story> _buildTestStories() {
  return List.generate(15, (i) {
    return Story(
      id: i,
      storyTitle: 'Story $i',
      choice1: 'Choice1_$i',
      choice2: i < 12 ? 'Choice2_$i' : '',
    );
  });
}

void main() {
  group('StoryBrain Logic Tests', () {
    late StoryBrain storyBrain;
    late GameState gameState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameState = GameState();
      await gameState.init();
      storyBrain = StoryBrain(gameState: gameState);
      // Manually set the stories so we don't need to load from assets
      storyBrain.state.stories.clear();
      storyBrain.loadTestStories(_buildTestStories());
    });

    test('Initial story index is 0', () {
      expect(storyBrain.currentStoryNumber, 0);
    });

    test('Choice 1 at start leads to story 1', () {
      storyBrain.nextStory(1);
      expect(storyBrain.currentStoryNumber, 1);
    });

    test('Choice 2 at start leads to story 2', () {
      storyBrain.nextStory(2);
      expect(storyBrain.currentStoryNumber, 2);
    });

    test('Ending 4: scary ending reached from story 1 choice 1', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(1); // 1 → 4
      expect(storyBrain.currentStoryNumber, 4);
      expect(storyBrain.isAtScaryEnding(), true);
      expect(storyBrain.isAtEnding(), true);
    });

    test('isAtEnding is false at non-ending story', () {
      expect(storyBrain.isAtEnding(), false); // at 0
      storyBrain.nextStory(1); // → 1
      expect(storyBrain.isAtEnding(), false);
    });

    test('buttonShouldBeVisible is false at ending', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(1); // 1 → 4 (ending)
      expect(storyBrain.buttonShouldBeVisible(), false);
    });

    test('nextStory returns ending index when reaching an ending', () {
      storyBrain.nextStory(1); // 0 → 1
      final result = storyBrain.nextStory(1); // 1 → 4
      expect(result, 4);
    });

    test('nextStory returns null when not at an ending', () {
      final result = storyBrain.nextStory(1); // 0 → 1
      expect(result, null);
    });

    test('Discovered endings are saved to GameState', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(1); // 1 → 4 (scary ending)
      expect(gameState.getDiscoveredEndings().contains(4), true);
    });

    test('Play count increments on restart', () {
      expect(gameState.getTotalPlays(), 0);
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(1); // 1 → 4 (ending)
      storyBrain.nextStory(1); // 4 → restart (increments plays)
      expect(gameState.getTotalPlays(), 1);
    });

    test('Ending 11: tearing the book', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(1); // 9 → 10
      storyBrain.nextStory(2); // 10 → 11
      expect(storyBrain.currentStoryNumber, 11);
      expect(storyBrain.isAtScaryEnding(), true);
    });

    test('Illusion path: story 9 choice 2 leads to 12 then 13', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(2); // 9 → 12
      expect(storyBrain.currentStoryNumber, 12);
      storyBrain.nextStory(1); // 12 → 13
      expect(storyBrain.currentStoryNumber, 13);
      expect(gameState.getHasBeenToIllusion(), true);
    });

    test('True ending (14) unlocked after seeing illusion', () async {
      // First run: reach illusion
      storyBrain.nextStory(1); storyBrain.nextStory(2); // 0→1→3
      storyBrain.nextStory(1); storyBrain.nextStory(1); // 3→5→7
      storyBrain.nextStory(2); storyBrain.nextStory(1); // 7→9→10
      storyBrain.nextStory(1); // 10 → 12 (no illusion yet)
      storyBrain.nextStory(1); // 12 → 13 (sets illusion flag)
      storyBrain.nextStory(1); // 13 → restart

      // Second run: true ending
      storyBrain.nextStory(1); storyBrain.nextStory(2); // 0→1→3
      storyBrain.nextStory(1); storyBrain.nextStory(1); // 3→5→7
      storyBrain.nextStory(2); storyBrain.nextStory(1); // 7→9→10
      storyBrain.nextStory(1); // 10 → 14 (illusion seen)
      expect(storyBrain.currentStoryNumber, 14);
      expect(storyBrain.isAtEnding(), true);
      expect(storyBrain.isAtScaryEnding(), false);
    });
  });
}
