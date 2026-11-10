import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AbjadiyatAlIbdaaApp());
}

/// تطبيق «أبجاديات الإبداع» — رحلة القراءة التفاعلية للأطفال
/// ملاحظة معمارية:
/// تم فصل أيقونة التشغيل الخارجية (Launcher Icon) تماماً عن واجهة التطبيق (main.dart)،
/// واستبدالها داخل الشاشة بكائن تعليمي متحرك وتفاعلي مرسوم بالكامل برمجياً (AnimatedEduOwlBuddy).
class AbjadiyatAlIbdaaApp extends StatelessWidget {
  const AbjadiyatAlIbdaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أبجاديات الإبداع',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'BalooBhaijaan2',
        scaffoldBackgroundColor: const Color(0xFFFFF9F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CE6),
          primary: const Color(0xFF7C5CE6),
          secondary: const Color(0xFFFACC15),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: ReadingJourneyHome(),
      ),
    );
  }
}

// ============================================================================
// 1. الكائن التعليمي المتحرك والتفاعلي داخل الشاشة (AnimatedEduOwlBuddy)
// بديل تفاعلي حي بالكامل داخل الواجهة بدلاً من صورة اللوجو الخارجية
// ============================================================================
enum BuddyMood { happy, excited, reading, proud }

class AnimatedEduOwlBuddy extends StatefulWidget {
  final double size;
  final BuddyMood? externalMood;
  final ValueChanged<String>? onSpeakPhrase;

  const AnimatedEduOwlBuddy({
    super.key,
    this.size = 160,
    this.externalMood,
    this.onSpeakPhrase,
  });

  @override
  State<AnimatedEduOwlBuddy> createState() => _AnimatedEduOwlBuddyState();
}

class _AnimatedEduOwlBuddyState extends State<AnimatedEduOwlBuddy>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _jumpCtrl;
  BuddyMood _mood = BuddyMood.happy;

  static const Map<BuddyMood, String> _phrases = {
    BuddyMood.happy: 'مرحباً بك في أبجاديات الإبداع! اضغط عليّ لنقرأ معاً',
    BuddyMood.excited: 'يا سلام! الحروف والحركات ممتعة جداً!',
    BuddyMood.reading: 'ركّز في التشكيل: الفتحة والضمة والكسرة والسكون!',
    BuddyMood.proud: 'أنت بطل القراءة المبدع! استمر في جمع النجوم!',
  };

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _jumpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _jumpCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    final moods = BuddyMood.values;
    final current = widget.externalMood ?? _mood;
    final nextMood = moods[(moods.indexOf(current) + 1) % moods.length];
    setState(() => _mood = nextMood);
    _jumpCtrl.forward(from: 0).then((_) => _jumpCtrl.reverse());
    widget.onSpeakPhrase?.call(_phrases[nextMood]!);
  }

  @override
  Widget build(BuildContext context) {
    final activeMood = widget.externalMood ?? _mood;
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _jumpCtrl]),
        builder: (context, child) {
          final floatOffset = math.sin(_floatCtrl.value * math.pi) * -10.0;
          final jumpOffset = math.sin(_jumpCtrl.value * math.pi) * -22.0;
          final scale = 1.0 + (_jumpCtrl.value * 0.08);
          return Transform.translate(
            offset: Offset(0, floatOffset + jumpOffset),
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _EduOwlPainter(
                    mood: activeMood,
                    wingProgress: _floatCtrl.value,
                    jumpProgress: _jumpCtrl.value,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EduOwlPainter extends CustomPainter {
  final BuddyMood mood;
  final double wingProgress;
  final double jumpProgress;

  _EduOwlPainter({
    required this.mood,
    required this.wingProgress,
    required this.jumpProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.56);

    // ظل الأرضية
    final shadowPaint = Paint()
      ..color = const Color(0xFF4C3D8F).withOpacity(0.16);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.92), width: w * 0.48, height: h * 0.08),
      shadowPaint,
    );

    // الأجنحة المتحركة
    final wingPaint = Paint()..color = const Color(0xFF3B82F6);
    final strokePaint = Paint()
      ..color = const Color(0xFF312E81)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;

    canvas.save();
    canvas.translate(w * 0.22, h * 0.56);
    canvas.rotate((wingProgress - 0.5) * 0.35 - (jumpProgress * 0.4));
    final leftWing = Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.32);
    canvas.drawOval(leftWing, wingPaint);
    canvas.drawOval(leftWing, strokePaint);
    canvas.restore();

    canvas.save();
    canvas.translate(w * 0.78, h * 0.56);
    canvas.rotate(-(wingProgress - 0.5) * 0.35 + (jumpProgress * 0.4));
    final rightWing = Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.32);
    canvas.drawOval(rightWing, wingPaint);
    canvas.drawOval(rightWing, strokePaint);
    canvas.restore();

    // الجسم الرئيسي للبومة الحكيمة "فصيح"
    final bodyRect = Rect.fromCenter(center: center, width: w * 0.54, height: h * 0.58);
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8B5CF6), Color(0xFF4C3D8F)],
      ).createShader(bodyRect);
    canvas.drawOval(bodyRect, bodyPaint);
    canvas.drawOval(bodyRect, strokePaint);

    // البطن الذهبي الفاتح
    final bellyRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.64),
      width: w * 0.38,
      height: h * 0.38,
    );
    canvas.drawOval(bellyRect, Paint()..color = const Color(0xFFFEF3C7));

    // العيون الذكية مع النظارة الذهبية
    final leftEyeCenter = Offset(w * 0.39, h * 0.45);
    final rightEyeCenter = Offset(w * 0.61, h * 0.45);
    final eyeRadius = w * 0.10;

    canvas.drawCircle(leftEyeCenter, eyeRadius, Paint()..color = Colors.white);
    canvas.drawCircle(rightEyeCenter, eyeRadius, Paint()..color = Colors.white);
    canvas.drawCircle(leftEyeCenter, eyeRadius, strokePaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius, strokePaint);

    final pupilRadius = w * 0.048;
    final dy = mood == BuddyMood.reading ? h * 0.02 : 0.0;
    canvas.drawCircle(leftEyeCenter.translate(0, dy), pupilRadius, Paint()..color = const Color(0xFF1E1B3A));
    canvas.drawCircle(rightEyeCenter.translate(0, dy), pupilRadius, Paint()..color = const Color(0xFF1E1B3A));

    // لمعة العين
    canvas.drawCircle(leftEyeCenter.translate(w * 0.018, -h * 0.018), w * 0.016, Paint()..color = Colors.white);
    canvas.drawCircle(rightEyeCenter.translate(w * 0.018, -h * 0.018), w * 0.016, Paint()..color = Colors.white);

    // إطار النظارة الذهبية
    final glassesPaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.016;
    canvas.drawCircle(leftEyeCenter, eyeRadius * 1.12, glassesPaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius * 1.12, glassesPaint);

    // المنقار البرتقالي
    final beakPath = Path()
      ..moveTo(w * 0.46, h * 0.50)
      ..lineTo(w * 0.54, h * 0.50)
      ..lineTo(w * 0.50, h * 0.57)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = const Color(0xFFFB923C));
    canvas.drawPath(beakPath, strokePaint);

    // قبعة التخرج التعليمية أعلى الرأس
    final capPath = Path()
      ..moveTo(w * 0.50, h * 0.13)
      ..lineTo(w * 0.74, h * 0.22)
      ..lineTo(w * 0.50, h * 0.30)
      ..lineTo(w * 0.26, h * 0.22)
      ..close();
    canvas.drawPath(capPath, Paint()..color = const Color(0xFF1E1B3A));
    canvas.drawPath(capPath, strokePaint);

    // الكتاب المفتوح أسفل الكائن التعليمي
    final bookRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, h * 0.82), width: w * 0.36, height: h * 0.10),
      const Radius.circular(8),
    );
    canvas.drawRRect(bookRect, Paint()..color = const Color(0xFFEC4899));
    canvas.drawRRect(bookRect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _EduOwlPainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.wingProgress != wingProgress ||
      oldDelegate.jumpProgress != jumpProgress;
}

// ============================================================================
// 2. بيانات المستويات الـ 7 والكلمات والجمل المُشَكَّلة
// ============================================================================
class WordSegment {
  final String text;
  final Color color;
  const WordSegment(this.text, this.color);
}

class LevelConfig {
  final int id;
  final String name;
  final String tag;
  final Color mainColor;
  final Color darkColor;
  final Color tintColor;
  final List<String> rawWords;
  final List<String> sentences;

  const LevelConfig({
    required this.id,
    required this.name,
    required this.tag,
    required this.mainColor,
    required this.darkColor,
    required this.tintColor,
    this.rawWords = const [],
    this.sentences = const [],
  });

  bool get isSentences => sentences.isNotEmpty;
  int get totalCount => isSentences ? sentences.length : rawWords.length;
}

const List<LevelConfig> kLevels = [
  LevelConfig(
    id: 0,
    name: 'المستوى الأول',
    tag: 'الفتحة',
    mainColor: Color(0xFF3B82F6),
    darkColor: Color(0xFF1D4ED8),
    tintColor: Color(0xFFDBEAFE),
    rawWords: [
      "دَ|*رَ|سَ", "سَرَدَ", "رَ|*سَ|بَ", "فَ|*رَ|سَ", "صَ|*مَ|دَ", "صَ|*بَرَ", "صَ|*دَ|رَ", "صَ|*دَ|مَ",
      "صَرَمَ", "رَ|*صَ|دَ", "نَ|*صَرَ", "نَ|*دَ|بَ", "نَ|*بَ|لَ", "بَ|*رَ|مَ", "بَ|*رَ|دَ", "دَ|*مَ|رَ",
      "رَ|*دَ|مَ", "نَ|*دَ|رَ", "رَ|*مَ|لَ", "لَ|*بَ|دَ", "مَ|*رَ|دَ", "دَ|*بَ|لَ", "نَ|*مَ|لَ", "بَ|*دَ|رَ",
      "دَ|*فَ|نَ", "رَ|*دَ|فَ", "فَ|*رَ|مَ", "رَ|*صَ|فَ", "نَ|*بَ|رَ", "فَ|*صَ|لَ"
    ],
  ),
  LevelConfig(
    id: 1,
    name: 'المستوى الثاني',
    tag: 'الضمة والكسرة',
    mainColor: Color(0xFF22C55E),
    darkColor: Color(0xFF15803D),
    tintColor: Color(0xFFDCFCE7),
    rawWords: [
      "سَ|*فَ|رُ", "بَ|*لَ|دُ", "لَ|*بَنُ", "بَ|*صَ|لُ", "بَ|*صَرُ", "نَ|*فَ|رُ", "رُ|*سِ|مَ", "نُ|*صِ|بَ",
      "رُ|*صِ|دَ", "نُ|*صِرَ", "مُ|*لِ|صَ", "رُ|*دِ|مَ", "نُ|*دِ|رَ", "بُ|*رِ|دَ", "فُ|*صِ|لَ", "صُرِفَ",
      "سُ|*فُ|نُ", "سُ|*بُ|لُ", "نَ|*دِ|مَ", "فُ|*رَ|صُ", "بَ|*صُرَ", "دَمُ", "مُ|*دُ|نُ", "بَ|*دَ|نُ"
    ],
  ),
  LevelConfig(
    id: 2,
    name: 'المستوى الثالث',
    tag: 'المدّ بالألف',
    mainColor: Color(0xFFF97316),
    darkColor: Color(0xFFC2410C),
    tintColor: Color(0xFFFFEDD5),
    rawWords: [
      "*بَا|بُ", "*دَا|رُ", "*نَا|مَ", "*مَا|لَ", "*نَا|رُ", "*لَا|مَ", "*دَا|مَ", "*دَا|بُ",
      "*رَا|مَ", "*نَا|لَ", "*بَا|نَ", "*نَا|بَ", "*نَا|بُ", "*سَا|مَ", "*صَا|مَ", "*صَا|دَ",
      "*صَا|لَ", "*مَا|لُ", "رُ|*بَا", "*سَا|لِمُ", "*نَا|دِرُ", "*سَا|فَرَ", "*نَا|دِمُ", "*بَا|دِرُ",
      "*فَا|صِلُ", "*صَا|دِرُ", "رِ|*مَا|لُ", "دَ|*لَا|لُ", "مُ|*صَا|بُ", "رَ|*بَا|بُ", "مُ|*رَا|دُ", "بِ|*لَا|لُ",
      "*بَابَا", "*مَامَا", "*سَا|رَ", "*نَا|رُ"
    ],
  ),
  LevelConfig(
    id: 3,
    name: 'المستوى الرابع',
    tag: 'المدّ بالواو',
    mainColor: Color(0xFFEC4899),
    darkColor: Color(0xFFBE185D),
    tintColor: Color(0xFFFCE7F3),
    rawWords: [
      "*دُولَا|بُ", "*نُو|رُ", "*دُو|دُ", "*سُو|رُ", "*بُو|مُ", "*نُو|نُ", "*دُو|رُ", "*مُو|لُ",
      "*صُو|صُ", "*صُو|فُ", "*فُو|لُ", "بَ|*نُو", "رَ|*سُو|لُ", "رُ|*سُو|مُ", "بَ|*نُو|نُ", "نَ|*صُو|مُ",
      "بُ|*دُو|رُ", "نُ|*مُو|رُ", "مُ|*رُو|رُ", "دُ|*رُو|بُ", "رُ|*فُو|فُ", "صُ|*فُو|فُ", "*نُو|رُ", "*سُو|رُ"
    ],
  ),
  LevelConfig(
    id: 4,
    name: 'المستوى الخامس',
    tag: 'المدّ بالياء',
    mainColor: Color(0xFF8B5CF6),
    darkColor: Color(0xFF6D28D9),
    tintColor: Color(0xFFEDE9FE),
    rawWords: [
      "*رَامِي", "*نَادِي", "*فِي", "*رِي|مُ", "*مِي|لُ", "*دِي|مُ", "*بِيرُ", "*دِي|نُ",
      "*لِينُ", "*سِي|مَ", "*فِي|لُ", "*رِي|فُ", "*دِيمَا", "بَ|*نِينَ", "بَ|*لِي|دُ", "رَ|*صِي|دُ",
      "نَ|*صِي|دُ", "مُ|*دِي|رُ", "بَ|*رِي|دُ", "رَ|*فِي|فُ", "بَلَ|*دِي"
    ],
  ),
  LevelConfig(
    id: 5,
    name: 'المستوى السادس',
    tag: 'السكون',
    mainColor: Color(0xFF14B8A6),
    darkColor: Color(0xFF0F766E),
    tintColor: Color(0xFFCCFBF1),
    rawWords: [
      "~صَفْ", "~رَفْ", "~مَنْ", "~صَدْ", "~نَسْرُ", "~دَرْ|سُ", "~نَسْ|لُ", "~رَسْ|مُ",
      "~نَمْ|لُ", "~صَبْرُ", "~مِصْرُ", "~نَصْرُ", "~رَصْ|دُ", "~بَنْ|دُ", "~صِفْ|رُ"
    ],
  ),
  LevelConfig(
    id: 6,
    name: 'المستوى السابع',
    tag: 'قراءة الجُمَل',
    mainColor: Color(0xFFFACC15),
    darkColor: Color(0xFFCA8A04),
    tintColor: Color(0xFFFEF9C3),
    sentences: [
      "نَامَ رَامِي.",
      "بَلَدُ دَلَالُ.",
      "صَامَ صَابِرُ.",
      "دَرَسَ نَاصِرُ.",
      "مَالُ سَامِي."
    ],
  ),
];

List<WordSegment> parseArabicWord(String raw) {
  return raw.split('|').map((part) {
    if (part.startsWith('*')) {
      return WordSegment(part.substring(1), const Color(0xFFD41818));
    } else if (part.startsWith('~')) {
      return WordSegment(part.substring(1), const Color(0xFF1E9E50));
    }
    return WordSegment(part, const Color(0xFF1E1B3A));
  }).toList();
}

// ============================================================================
// 3. الهيكل الرئيسي لشاشات الموبايل (ReadingJourneyHome)
// ============================================================================
class ReadingJourneyHome extends StatefulWidget {
  const ReadingJourneyHome({super.key});

  @override
  State<ReadingJourneyHome> createState() => _ReadingJourneyHomeState();
}

class _ReadingJourneyHomeState extends State<ReadingJourneyHome> {
  int _tabIndex = 0; // 0: الرئيسية, 1: الخريطة, 2: القراءة, 3: إنجازاتي
  int _selectedLevel = 0;
  int _selectedItemIndex = 0;
  bool _isGridMode = true;
  String _buddySpeech = 'مرحباً يا بطل! اضغط عليّ لنستكشف الحروف معاً';
  final Set<String> _readItems = {};

  bool _isRead(int lv, int idx) => _readItems.contains('$lv-$idx');
  int _levelReadCount(int lv) =>
      _readItems.where((k) => k.startsWith('$lv-')).length;

  void _toggleRead(int lv, int idx) {
    final key = '$lv-$idx';
    setState(() {
      if (_readItems.contains(key)) {
        _readItems.remove(key);
        _buddySpeech = 'حاول قراءتها مرة أخرى بصوت واضح!';
      } else {
        _readItems.add(key);
        _buddySpeech = 'رائع جداً! حصلت على نجمة ذهبية جديدة ★';
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.94),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // أفاتار مصغر للكائن التعليمي المتحرك بدلاً من صورة اللوجو الخارجية
            const SizedBox(
              width: 42,
              height: 42,
              child: AnimatedEduOwlBuddy(size: 42),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أبجاديات الإبداع',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Color(0xFF4C3D8F),
                  ),
                ),
                Text(
                  'رحلة القراءة التفاعلية',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Color(0xFF8A86A3),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFDE68A), width: 2.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFEAB308), size: 22),
                const SizedBox(width: 4),
                Text(
                  '${_readItems.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFFA16207),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _buildCoverTab(),
          _buildMapTab(),
          _buildPracticeTab(),
          _buildRewardsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEDE9FE),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_rounded),
            label: 'الخريطة',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'القراءة',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_rounded),
            label: 'إنجازاتي',
          ),
        ],
      ),
    );
  }

  // الشاشة الرئيسية: الكائن التعليمي المتحرك التفاعلي + فقاعة الحوار الذكية
  Widget _buildCoverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // فقاعة حوار تفاعلية للكائن التعليمي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDCCFFA), width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFE3DDF5),
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              _buddySpeech,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4C3D8F),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // الكائن التعليمي المتحرك كعنصر تفاعلي رئيسي في منتصف الشاشة
          AnimatedEduOwlBuddy(
            size: 190,
            onSpeakPhrase: (phrase) {
              setState(() => _buddySpeech = phrase);
            },
          ),
          const SizedBox(height: 20),

          const Text(
            'أبجاديات الإبداع',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4C3D8F),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'رحلة القراءة التفاعلية في 7 مستويات مع صديقك «فصيح»',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A4766),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CE6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 6,
              ),
              onPressed: () => setState(() => _tabIndex = 1),
              icon: const Icon(Icons.play_arrow_rounded, size: 30),
              label: const Text(
                'ابدأ رحلة القراءة',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: kLevels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final lv = kLevels[i];
        final done = _levelReadCount(i);
        final total = lv.totalCount;
        return InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () => setState(() {
            _selectedLevel = i;
            _selectedItemIndex = 0;
            _tabIndex = 2;
          }),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: lv.tintColor, width: 3),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: lv.mainColor,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lv.name,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        lv.tag,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: lv.darkColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$done / $total ★',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: lv.darkColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPracticeTab() {
    final lv = kLevels[_selectedLevel];
    if (_isGridMode && !lv.isSentences) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${lv.name} · ${lv.tag}',
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _isGridMode = false),
                  icon: const Icon(Icons.fullscreen_rounded),
                  label: const Text('كلمة كلمة'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.35,
              ),
              itemCount: lv.rawWords.length,
              itemBuilder: (context, idx) {
                final segs = parseArabicWord(lv.rawWords[idx]);
                final read = _isRead(_selectedLevel, idx);
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedItemIndex = idx;
                    _isGridMode = false;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: read ? const Color(0xFF4ADE80) : lv.tintColor,
                        width: 3,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'BalooBhaijaan2',
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                        children: segs
                            .map((s) => TextSpan(
                                  text: s.text,
                                  style: TextStyle(color: s.color),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // شاشة القراءة المركزة مع الكائن التعليمي المتفاعل
    final total = lv.totalCount;
    final idx = _selectedItemIndex.clamp(0, total - 1);
    final read = _isRead(_selectedLevel, idx);
    final segs = lv.isSentences ? <WordSegment>[] : parseArabicWord(lv.rawWords[idx]);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${lv.name} (${idx + 1}/$total)',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              if (!lv.isSentences)
                TextButton.icon(
                  onPressed: () => setState(() => _isGridMode = true),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('الشبكة'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AnimatedEduOwlBuddy(
                size: 64,
                externalMood: read ? BuddyMood.proud : BuddyMood.reading,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _buddySpeech,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4C3D8F),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleRead(_selectedLevel, idx),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: read ? const Color(0xFF22C55E) : lv.tintColor,
                    width: 4,
                  ),
                ),
                alignment: Alignment.center,
                child: lv.isSentences
                    ? Text(
                        lv.sentences[idx],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
                      )
                    : RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'BalooBhaijaan2',
                            fontSize: 70,
                            fontWeight: FontWeight.w800,
                          ),
                          children: segs
                              .map((s) => TextSpan(text: s.text, style: TextStyle(color: s.color)))
                              .toList(),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: read ? const Color(0xFF22C55E) : const Color(0xFFFACC15),
                foregroundColor: read ? Colors.white : const Color(0xFF7C4A03),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              onPressed: () => _toggleRead(_selectedLevel, idx),
              icon: Icon(read ? Icons.check_circle_rounded : Icons.star_rounded, size: 28),
              label: Text(
                read ? 'أحسنت! قرأتها' : 'قرأتها (+1 نجمة)',
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedEduOwlBuddy(
            size: 150,
            externalMood: BuddyMood.proud,
          ),
          const SizedBox(height: 16),
          const Text(
            'أحسنت يا بطل أبجاديات الإبداع!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF4C3D8F)),
          ),
          const SizedBox(height: 8),
          Text(
            'جمعت ${_readItems.length} نجمة من أصل 155',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
