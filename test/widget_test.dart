import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:destini_starting_master/story_brain.dart';
import 'package:destini_starting_master/game_state.dart';

void main() {
  group('StoryBrain Tests', () {
    late StoryBrain storyBrain;
    late GameState gameState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameState = GameState();
      await gameState.init();
      storyBrain = StoryBrain(gameState: gameState);
    });

    test('Initial story is at index 0', () {
      expect(storyBrain.getStory(), contains('سيارتك تعطلت'));
    });

    test('Choice 1 at start leads to story 1', () {
      storyBrain.nextStory(1);
      expect(storyBrain.getStory(), contains('بوابات الظلال'));
    });

    test('Choice 2 at start leads to story 2', () {
      storyBrain.nextStory(2);
      expect(storyBrain.getStory(), contains('نسختك من المستقبل'));
    });

    test('Ending 4: scary ending (dead end)', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(1); // 1 → 4
      expect(storyBrain.getStory(), contains('صحراء لا تنتهي'));
      expect(storyBrain.buttonShouldBeVisible(), false);
      expect(storyBrain.isAtScaryEnding(), true);
    });

    test('Ending 11: tearing the book', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(1); // 9 → 10
      storyBrain.nextStory(2); // 10 → 11
      expect(storyBrain.getStory(), contains('تمزيق الكتاب'));
      expect(storyBrain.buttonShouldBeVisible(), false);
    });

    test('Ending 12→13: illusion path', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(2); // 9 → 12
      expect(storyBrain.getStory(), contains('عالم جميل وهادئ'));
      storyBrain.nextStory(1); // 12 → 13
      expect(storyBrain.getStory(), contains('كل شيء زائف'));
    });

    test('Ending 14: true ending after seeing illusion', () {
      // First: reach illusion
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(1); // 9 → 10
      storyBrain.nextStory(1); // 10 → 12
      storyBrain.nextStory(1); // 12 → 13 (sets illusion flag)
      storyBrain.nextStory(1); // 13 → restart

      // Second: true ending unlock
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(1); // 9 → 10
      storyBrain.nextStory(1); // 10 → 14

      expect(storyBrain.getStory(), contains('أنا لست من أريد الخروج'));
      expect(storyBrain.isAtEnding(), true);
      expect(storyBrain.isAtScaryEnding(), false);
    });

    test('Discovered endings are saved to GameState', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(1); // 1 → 4 (scary ending)
      expect(gameState.getDiscoveredEndings().contains(4), true);
    });

    test('Play count increments on restart', () {
      expect(gameState.getTotalPlays(), 0);
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(1); // 1 → 4
      storyBrain.nextStory(1); // 4 → restart (increments plays)
      expect(gameState.getTotalPlays(), 1);
    });

    test('nextStory returns ending index when reaching an ending', () {
      storyBrain.nextStory(1); // 0 → 1
      final result = storyBrain.nextStory(1); // 1 → 4
      expect(result, 4);
    });
  });
}
