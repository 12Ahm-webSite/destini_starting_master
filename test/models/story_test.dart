import 'package:flutter_test/flutter_test.dart';
import 'package:destini_starting_master/models/story.dart';

void main() {
  group('Story Model Tests', () {
    test('Story.fromJson parses all fields correctly', () {
      final json = {
        'id': 0,
        'storyTitle': 'Test story title',
        'choice1': 'Choice A',
        'choice2': 'Choice B',
      };
      final story = Story.fromJson(json);
      expect(story.id, 0);
      expect(story.storyTitle, 'Test story title');
      expect(story.choice1, 'Choice A');
      expect(story.choice2, 'Choice B');
    });

    test('Story.fromJson handles empty choice2', () {
      final json = {
        'id': 4,
        'storyTitle': 'Ending story',
        'choice1': 'Restart',
        'choice2': '',
      };
      final story = Story.fromJson(json);
      expect(story.id, 4);
      expect(story.choice2, '');
    });

    test('Story.fromJson handles missing choice2 (null)', () {
      final json = {
        'id': 5,
        'storyTitle': 'Another story',
        'choice1': 'Go forward',
        // no 'choice2' key
      };
      final story = Story.fromJson(json);
      expect(story.choice2, '');
    });

    test('Story.toJson produces correct map', () {
      const story = Story(
        id: 1,
        storyTitle: 'Hello',
        choice1: 'Yes',
        choice2: 'No',
      );
      final json = story.toJson();
      expect(json['id'], 1);
      expect(json['storyTitle'], 'Hello');
      expect(json['choice1'], 'Yes');
      expect(json['choice2'], 'No');
    });

    test('Story.listFromJson parses a list from JSON string', () {
      const jsonStr = '''
      {
        "stories": [
          {"id": 0, "storyTitle": "First", "choice1": "A", "choice2": "B"},
          {"id": 1, "storyTitle": "Second", "choice1": "C", "choice2": ""}
        ]
      }
      ''';
      final stories = Story.listFromJson(jsonStr);
      expect(stories.length, 2);
      expect(stories[0].id, 0);
      expect(stories[1].storyTitle, 'Second');
    });
  });
}
