import 'package:flutter_test/flutter_test.dart';
import 'package:destini_starting_master/story_brain.dart';

void main() {
  group('StoryBrain Tests', () {
    late StoryBrain storyBrain;

    setUp(() {
      storyBrain = StoryBrain();
    });

    test('Initial story is at index 0', () {
      expect(storyBrain.getStory(), contains('سيارتك تعطلت'));
    });

    test('Choice 1 at start leads to story 1 (الركوب مع الرجل)', () {
      storyBrain.nextStory(1); // 0 → 1
      expect(storyBrain.getStory(), contains('بوابات الظلال'));
    });

    test('Choice 2 at start leads to story 2 (الرفض والانتظار)', () {
      storyBrain.nextStory(2); // 0 → 2
      expect(storyBrain.getStory(), contains('نسختك من المستقبل'));
    });

    test('Ending 4: صحراء لا تنتهي (dead end)', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(1); // 1 → 4
      expect(storyBrain.getStory(), contains('صحراء لا تنتهي'));
      expect(storyBrain.buttonShouldBeVisible(), false);
      storyBrain.nextStory(1); // restart
      expect(storyBrain.getStory(), contains('سيارتك تعطلت'));
    });

    test('Ending 6: سواد لا نهائي (via path 0→2→2)', () {
      storyBrain.nextStory(2); // 0 → 2
      storyBrain.nextStory(2); // 2 → 6
      expect(storyBrain.getStory(), contains('سواد لا نهائي'));
      expect(storyBrain.buttonShouldBeVisible(), false);
    });

    test('Ending 6: سواد لا نهائي (via path 0→1→2→3→2)', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(2); // 3 → 6
      expect(storyBrain.getStory(), contains('سواد لا نهائي'));
    });

    test('Ending 8: داخل التمثال', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(1); // 7 → 8
      expect(storyBrain.getStory(), contains('تدخل داخله'));
      expect(storyBrain.buttonShouldBeVisible(), false);
    });

    test('Ending 11: تمزيق الكتاب (choice 2 at story 10)', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(1); // 9 → 10
      storyBrain.nextStory(2); // 10 → 11 (تمزيق الكتاب)
      expect(storyBrain.getStory(), contains('تمزيق الكتاب'));
      expect(storyBrain.buttonShouldBeVisible(), false);
    });

    test('Ending 12→13: الوهم (first time through portal)', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(2); // 9 → 12 (تشغيل الآلة مباشرة)
      expect(storyBrain.getStory(), contains('عالم جميل وهادئ'));
      storyBrain.nextStory(1); // 12 → 13 (الوهم)
      expect(storyBrain.getStory(), contains('كل شيء زائف'));
      expect(storyBrain.buttonShouldBeVisible(), false);
    });

    test('Ending 12→13 via book path (first time): read book then open portal', () {
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(1); // 9 → 10 (قراءة الكتاب)
      storyBrain.nextStory(1); // 10 → 12 (first time, no illusion flag)
      expect(storyBrain.getStory(), contains('عالم جميل وهادئ'));
      storyBrain.nextStory(1); // 12 → 13
      expect(storyBrain.getStory(), contains('كل شيء زائف'));
    });

    test('Ending 14: النهاية الحقيقية (after seeing illusion)', () {
      // First playthrough: reach illusion ending
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(1); // 9 → 10
      storyBrain.nextStory(1); // 10 → 12 (first time)
      storyBrain.nextStory(1); // 12 → 13 (sets illusion flag)
      storyBrain.nextStory(1); // 13 → restart

      // Second playthrough: true ending unlocked
      storyBrain.nextStory(1); // 0 → 1
      storyBrain.nextStory(2); // 1 → 3
      storyBrain.nextStory(1); // 3 → 5
      storyBrain.nextStory(1); // 5 → 7
      storyBrain.nextStory(2); // 7 → 9
      storyBrain.nextStory(1); // 9 → 10
      storyBrain.nextStory(1); // 10 → 14 (true ending!)

      expect(storyBrain.getStory(), contains('أنا لست من أريد الخروج'));
      expect(storyBrain.buttonShouldBeVisible(), false);

      // Case 14 restarts and resets illusion flag
      storyBrain.nextStory(1); // 14 → restart
      expect(storyBrain.getStory(), contains('سيارتك تعطلت'));
    });

    test('Second button visibility correctly toggles', () {
      // Story 0 has two choices
      expect(storyBrain.buttonShouldBeVisible(), true);

      // Navigate to dead end (story 4) - only one button
      storyBrain.nextStory(1); // 0 → 1
      expect(storyBrain.buttonShouldBeVisible(), true);
      storyBrain.nextStory(1); // 1 → 4
      expect(storyBrain.buttonShouldBeVisible(), false);
    });
  });
}
