import 'package:shared_preferences/shared_preferences.dart';

/// Manages game state persistence: discovered endings, achievements, and illusion flag.
class GameState {
  static const String _endingsKey = 'discovered_endings';
  static const String _illusionKey = 'has_been_to_illusion';
  static const String _totalPlaysKey = 'total_plays';

  late SharedPreferences _prefs;

  // All possible ending story indices
  static const List<int> allEndings = [4, 6, 8, 11, 13, 14];

  // Ending metadata
  static const Map<int, EndingInfo> endingDetails = {
    4: EndingInfo(
      title: 'صحراء بلا نهاية',
      description: 'تجد نفسك في صحراء لا تنتهي، الزمن متجمد.',
      icon: '🏜️',
      type: EndingType.scary,
    ),
    6: EndingInfo(
      title: 'السواد اللانهائي',
      description: 'الطريق اختفى. كل شيء تحول إلى سواد.',
      icon: '🕳️',
      type: EndingType.scary,
    ),
    8: EndingInfo(
      title: 'سجين التمثال',
      description: 'دخلت داخل التمثال. حياتك تتكرر بلا نهاية.',
      icon: '🗿',
      type: EndingType.scary,
    ),
    11: EndingInfo(
      title: 'الدوامة الأبدية',
      description: 'مزقت الكتاب وانهارت الأرض.',
      icon: '🌀',
      type: EndingType.scary,
    ),
    13: EndingInfo(
      title: 'الوهم',
      description: 'العالم الجميل كان سجنًا ذكيًا.',
      icon: '🎭',
      type: EndingType.illusion,
    ),
    14: EndingInfo(
      title: 'الحقيقة',
      description: 'اكتشفت الحقيقة المخفية وبدأت عملية الإعادة.',
      icon: '✨',
      type: EndingType.trueEnding,
    ),
  };

  // Achievement definitions
  static final List<Achievement> achievements = [
    Achievement(
      id: 'first_death',
      title: 'أول سقوط',
      description: 'وصلت لأول نهاية مرعبة',
      icon: '💀',
      condition: (endings, plays) => endings.isNotEmpty,
    ),
    Achievement(
      id: 'all_scary',
      title: 'جامع الكوابيس',
      description: 'اكتشفت كل النهايات المرعبة',
      icon: '👻',
      condition: (endings, plays) =>
          [4, 6, 8, 11].every((e) => endings.contains(e)),
    ),
    Achievement(
      id: 'illusion',
      title: 'ضحية الوهم',
      description: 'دخلت عالم الوهم',
      icon: '🎭',
      condition: (endings, plays) => endings.contains(13),
    ),
    Achievement(
      id: 'true_ending',
      title: 'الباحث عن الحقيقة',
      description: 'وصلت للنهاية الحقيقية',
      icon: '🌟',
      condition: (endings, plays) => endings.contains(14),
    ),
    Achievement(
      id: 'all_endings',
      title: 'سيد المصير',
      description: 'اكتشفت كل النهايات الستة',
      icon: '👑',
      condition: (endings, plays) => endings.length >= 6,
    ),
    Achievement(
      id: 'persistent',
      title: 'المثابر',
      description: 'أعدت اللعب 5 مرات',
      icon: '🔄',
      condition: (endings, plays) => plays >= 5,
    ),
  ];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Discovered Endings ---

  Set<int> getDiscoveredEndings() {
    final list = _prefs.getStringList(_endingsKey) ?? [];
    return list.map((e) => int.parse(e)).toSet();
  }

  Future<void> addDiscoveredEnding(int endingIndex) async {
    final endings = getDiscoveredEndings();
    endings.add(endingIndex);
    await _prefs.setStringList(
      _endingsKey,
      endings.map((e) => e.toString()).toList(),
    );
  }

  int get discoveredCount => getDiscoveredEndings().length;
  int get totalEndings => allEndings.length;

  // --- Illusion Flag ---

  bool getHasBeenToIllusion() {
    return _prefs.getBool(_illusionKey) ?? false;
  }

  Future<void> setHasBeenToIllusion(bool value) async {
    await _prefs.setBool(_illusionKey, value);
  }

  // --- Play Counter ---

  int getTotalPlays() {
    return _prefs.getInt(_totalPlaysKey) ?? 0;
  }

  Future<void> incrementPlays() async {
    await _prefs.setInt(_totalPlaysKey, getTotalPlays() + 1);
  }

  // --- Achievements ---

  List<Achievement> getUnlockedAchievements() {
    final endings = getDiscoveredEndings();
    final plays = getTotalPlays();
    return achievements
        .where((a) => a.condition(endings, plays))
        .toList();
  }

  int get unlockedAchievementCount => getUnlockedAchievements().length;
  int get totalAchievements => achievements.length;

  // --- Reset ---

  Future<void> resetAll() async {
    await _prefs.remove(_endingsKey);
    await _prefs.remove(_illusionKey);
    await _prefs.remove(_totalPlaysKey);
  }
}

enum EndingType { scary, illusion, trueEnding }

class EndingInfo {
  final String title;
  final String description;
  final String icon;
  final EndingType type;

  const EndingInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool Function(Set<int> endings, int plays) condition;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.condition,
  });
}
