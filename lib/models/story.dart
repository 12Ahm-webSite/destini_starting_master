import 'dart:convert';

class Story {
  final int id;
  final String storyTitle;
  final String choice1;
  final String choice2;

  const Story({
    required this.id,
    required this.storyTitle,
    required this.choice1,
    required this.choice2,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as int,
      storyTitle: json['storyTitle'] as String,
      choice1: json['choice1'] as String,
      choice2: json['choice2'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'storyTitle': storyTitle,
        'choice1': choice1,
        'choice2': choice2,
      };

  static List<Story> listFromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['stories'] as List<dynamic>;
    return list
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() => 'Story(id: $id, title: $storyTitle)';
}
