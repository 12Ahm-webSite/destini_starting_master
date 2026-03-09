import 'story.dart';
import 'game_state.dart';

class StoryBrain {
  int _storyNumber = 0;
  final GameState gameState;

  // Endings that trigger haptic feedback (scary endings)
  static const Set<int> scaryEndings = {4, 6, 8, 11};
  // All ending indices
  static const Set<int> allEndingIndices = {4, 6, 8, 11, 12, 13, 14};

  StoryBrain({required this.gameState}) {
    // Restore illusion flag from saved state
  }

  bool get playerHasBeenToIllusion => gameState.getHasBeenToIllusion();

  final List<Story> _storyData = [
    // 0 - البداية
    Story(
      storyTitle:
          'سيارتك تعطلت في طريق صحراوي مهجور. بعد ساعات، ظهر رجل غريب في شاحنة قديمة ويعرض عليك توصيلك.',
      choice1: 'اركب معه.',
      choice2: 'ارفض وانتظر.',
    ),

    // 1 - الركوب مع الرجل
    Story(
      storyTitle:
          'يبدأ يتحدث عن "بوابات الظلال"، ويقول إنه يعرف طريقًا مختصرًا يقود إلى عالم أنقى.',
      choice1: 'اطلب منه التوقف.',
      choice2: 'اطلب أن تراه هذا الاختصار.',
    ),

    // 2 - الرفض والانتظار
    Story(
      storyTitle:
          'بعد فترة، تجد نفسك أمام نسختك من المستقبل، يقول إنك ستندم على اختياراتك.',
      choice1: 'تصدقه وتغادر.',
      choice2: 'ترفض وتحاول العودة.',
    ),

    // 3 - الوصول إلى الكهف
    Story(
      storyTitle:
          'الرجل يتركك أمام كهف غريب ويقول: "ادخل، الحقيقة تنتظرك بالداخل".',
      choice1: 'تدخل الكهف.',
      choice2: 'ترفض وتحاول العودة.',
    ),

    // 4 - نهاية مرعبة 1: الخروج المبكر
    Story(
      storyTitle:
          'تجد نفسك في صحراء لا تنتهي، الزمن متجمد، وكل من تراه يشبهك. تبدأ تفقد هويتك.',
      choice1: 'ابدأ مجددًا',
      choice2: '',
    ),

    // 5 - دخول المدينة تحت الأرض
    Story(
      storyTitle:
          'تكتشف مدينة تحت الأرض، الهواء سميك، والأصوات تشبه صوتك. تشعر أنك مراقب.',
      choice1: 'تواصل التقدم.',
      choice2: 'تحاول العودة.',
    ),

    // 6 - نهاية مرعبة 2: العودة بدون طريق
    Story(
      storyTitle:
          'تحاول العودة، لكن الطريق قد اختفى. كل شيء حولك يتحول إلى سواد لا نهائي.',
      choice1: 'ابدأ مجددًا',
      choice2: '',
    ),

    // 7 - المعبد والتماثيل
    Story(
      storyTitle:
          'في قلب المدينة، تجد معبدًا مليئًا بتماثيل تشبهك. أحدها يفتح عينيه فجأة.',
      choice1: 'تلمس التمثال.',
      choice2: 'تحطم التماثيل.',
    ),

    // 8 - نهاية مرعبة 3: لمس التمثال
    Story(
      storyTitle:
          'بلمس التمثال، تدخل داخله. تشاهد حياتك تتكرر بلا نهاية، ولا تستطيع التحدث.',
      choice1: 'ابدأ مجددًا',
      choice2: '',
    ),

    // 9 - تحطيم التماثيل
    Story(
      storyTitle:
          'التماثيل تنكسر، وتنكشف غرفة مضيئة تحتوي على آلة بوابة، وبجانبها كتاب.',
      choice1: 'تقرأ الكتاب.',
      choice2: 'تشغل الآلة مباشرة.',
    ),

    // 10 - قراءة الكتاب
    Story(
      storyTitle:
          'الكتاب يصف كل قراراتك بدقة، وينتهي بجملة: "الحقيقة ليست هنا... هي عندك."',
      choice1: 'تفتح البوابة.',
      choice2: 'تمزق الكتاب.',
    ),

    // 11 - نهاية مرعبة 4: تمزيق الكتاب
    Story(
      storyTitle:
          'بتمزيق الكتاب، تنهار الأرض وتسقط في دوامة لا نهائية. كل ما كنت عليه يُمحى.',
      choice1: 'ابدأ مجددًا',
      choice2: '',
    ),

    // 12 - تشغيل البوابة (بدون قراءة الكتاب)
    Story(
      storyTitle:
          'تشغل الآلة، وتنتقل إلى عالم جميل وهادئ. الشمس تشرق، والناس يبتسمون لك.',
      choice1: 'ابدأ مجددًا',
      choice2: '',
    ),

    // 13 - النهاية السادسة: "الوهم"
    Story(
      storyTitle:
          'بعد وقت، تدرك أن كل شيء زائف. الناس لا يتغيرون، والزمن متجمد. لقد دخلت سجنًا ذكيًا.',
      choice1: 'ابدأ مجددًا',
      choice2: '',
    ),

    // 14 - النهاية السعيدة الحقيقية
    Story(
      storyTitle:
          'تتذكر كل ما حدث من قبل. تعود إلى المعبد وتضع يدك على التمثال الأخير. تقول: "أنا لست من أريد الخروج... أنا من يجب أن يُمحى."',
      choice1: 'تبدأ عملية الإعادة.',
      choice2: '',
    ),
  ];

  String getStory() => _storyData[_storyNumber].storyTitle;
  String getChoice1() => _storyData[_storyNumber].choice1;
  String getChoice2() => _storyData[_storyNumber].choice2;
  int get currentStoryNumber => _storyNumber;

  bool isAtEnding() => allEndingIndices.contains(_storyNumber);
  bool isAtScaryEnding() => scaryEndings.contains(_storyNumber);

  /// Returns the new ending index if we just arrived at an ending, or null.
  int? nextStory(int choiceNumber) {
    int? reachedEnding;

    switch (_storyNumber) {
      case 0:
        _storyNumber = (choiceNumber == 1) ? 1 : 2;
        break;

      case 1:
        _storyNumber = (choiceNumber == 1) ? 4 : 3;
        break;

      case 2:
        _storyNumber = (choiceNumber == 1) ? 5 : 6;
        break;

      case 3:
        _storyNumber = (choiceNumber == 1) ? 5 : 6;
        break;

      case 5:
        _storyNumber = (choiceNumber == 1) ? 7 : 6;
        break;

      case 7:
        _storyNumber = (choiceNumber == 1) ? 8 : 9;
        break;

      case 9:
        _storyNumber = (choiceNumber == 1) ? 10 : 12;
        break;

      case 10:
        if (choiceNumber == 1) {
          _storyNumber = playerHasBeenToIllusion ? 14 : 12;
        } else {
          _storyNumber = 11;
        }
        break;

      case 12:
        gameState.setHasBeenToIllusion(true);
        _storyNumber = 13;
        break;

      case 13:
        gameState.incrementPlays();
        restart();
        break;

      case 14:
        gameState.setHasBeenToIllusion(false);
        gameState.incrementPlays();
        restart();
        break;

      case 4:
      case 6:
      case 8:
      case 11:
        gameState.incrementPlays();
        restart();
        break;
    }

    // Check if we arrived at an ending
    if (allEndingIndices.contains(_storyNumber)) {
      reachedEnding = _storyNumber;
      // Save the ending as discovered (for endings that get displayed before restart)
      if ([4, 6, 8, 11, 13, 14].contains(_storyNumber)) {
        gameState.addDiscoveredEnding(_storyNumber);
      }
    }

    return reachedEnding;
  }

  void restart() {
    _storyNumber = 0;
  }

  bool buttonShouldBeVisible() {
    return [0, 1, 2, 3, 5, 7, 9, 10].contains(_storyNumber);
  }
}