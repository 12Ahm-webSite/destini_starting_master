import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../widgets/fog_effect.dart';

class AchievementsScreen extends StatelessWidget {
  final GameState gameState;
  final String locale;
  const AchievementsScreen({
    super.key,
    required this.gameState,
    this.locale = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    final discoveredEndings = gameState.getDiscoveredEndings();
    final unlockedAchievements = gameState.getUnlockedAchievements();
    final totalPlays = gameState.getTotalPlays();
    final isAr = locale == 'ar';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D0D0D), Color(0xFF1A0A0A)],
              ),
            ),
          ),
          const FogEffect(particleCount: 15),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                      ),
                      Expanded(
                        child: Text(
                          isAr ? 'إنجازاتك' : 'Achievements',
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Stats bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatChip('🎮', '$totalPlays', isAr ? 'مرة لعب' : 'Plays'),
                      _buildStatChip(
                        '📖',
                        '${discoveredEndings.length}/${GameState.allEndings.length}',
                        isAr ? 'نهايات' : 'Endings',
                      ),
                      _buildStatChip(
                        '🏆',
                        '${unlockedAchievements.length}/${GameState.achievements.length}',
                        isAr ? 'إنجازات' : 'Achievements',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Endings section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      isAr ? 'النهايات المكتشفة' : 'Discovered Endings',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: GameState.allEndings.length,
                    itemBuilder: (context, index) {
                      final endingId = GameState.allEndings[index];
                      final info = GameState.endingDetails[endingId]!;
                      final discovered = discoveredEndings.contains(endingId);
                      return _buildEndingCard(info, discovered, isAr);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Achievements section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      isAr ? 'الإنجازات' : 'Achievements',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: GameState.achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = GameState.achievements[index];
                      final unlocked = unlockedAchievements.contains(achievement);
                      return _buildAchievementTile(achievement, unlocked, isAr);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.cairo(
                  fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(label,
              style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildEndingCard(EndingInfo info, bool discovered, bool isAr) {
    final Color borderColor;
    switch (info.type) {
      case EndingType.scary:
        borderColor = Colors.red.withOpacity(discovered ? 0.6 : 0.15);
        break;
      case EndingType.illusion:
        borderColor = Colors.purple.withOpacity(discovered ? 0.6 : 0.15);
        break;
      case EndingType.trueEnding:
        borderColor = Colors.amber.withOpacity(discovered ? 0.6 : 0.15);
        break;
    }

    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(discovered ? 0.08 : 0.03),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: discovered
            ? [BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 10)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(discovered ? info.icon : '❓',
              style: TextStyle(fontSize: discovered ? 32 : 28)),
          const SizedBox(height: 8),
          Text(
            discovered ? (isAr ? info.title : info.titleEn) : '???',
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: discovered ? Colors.white : Colors.white24,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Achievement achievement, bool unlocked, bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: unlocked
            ? Colors.amber.withOpacity(0.08)
            : Colors.white.withOpacity(0.03),
        border: Border.all(
          color: unlocked
              ? Colors.amber.withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? Colors.amber.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
            ),
            child: Center(
              child: Text(unlocked ? achievement.icon : '🔒',
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unlocked
                      ? (isAr ? achievement.title : achievement.titleEn)
                      : '???',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: unlocked ? Colors.white : Colors.white30,
                  ),
                ),
                Text(
                  unlocked
                      ? achievement.description
                      : (isAr ? 'لم يُكتشف بعد' : 'Not yet discovered'),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: unlocked ? Colors.white54 : Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
