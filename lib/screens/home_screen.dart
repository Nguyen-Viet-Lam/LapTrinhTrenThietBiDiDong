import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_controller.dart';
import '../models.dart';
import 'design_v2_widgets.dart';
import 'quest_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final user = controller.currentUser;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Giao diện chuyên biệt cho Admin (Admin chỉ quản trị & giám sát, không làm nhiệm vụ)
    // Áp dụng chuẩn Phong cách 2: Deep Abyss Ocean Glass (Hình 2: Kính đại dương sâu thẳm)
    if (user.isAdmin) {
      return _buildAdminDashboard(context, user, controller);
    }

    // Giao diện cho Người dùng (User):
    // Áp dụng chuẩn Phong cách 1: Nova Glass (Hình 1: Kính băng tuyết trong trẻo, bo góc mềm, đổ bóng dịu)
    final active = controller.myQuests
        .where((quest) => quest.status == QuestStatus.active)
        .take(5)
        .toList();

    final levelStart = (user.level - 1) * (user.level - 1) * 100;
    final levelEnd = user.level * user.level * 100;
    final span = levelEnd - levelStart;
    final levelProgress = span > 0 ? (user.xp - levelStart) / span : 0.0;
    final xpNeeded = controller.stats?.xpToNextLevel ?? (levelEnd - user.xp);

    return RefreshIndicator(
      onRefresh: () async => await controller.refreshAllData(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [
          // 1. Novara Alpine Hero Section with Floating Frosted Glass Card & Glowing Neon Chart (Hình mẫu Novara)
          _buildNovaraHeroSection(context, user, controller, active.length),
          const SizedBox(height: 24),

          // 2. Novara 5 Pillars Grid (Core Domains: Thể thao, Học tập, Kỷ luật, Cân bằng, Đồng đội)
          _buildNovaraFivePillarsGrid(context),
          const SizedBox(height: 24),

          // 3. Novara Mountaineer Featured Banner & Testimonial
          _buildNovaraFeaturedAndQuote(context),
          const SizedBox(height: 24),

          // 4. Novara Metrics Bar (100% Idempotent, 4.9/5 AI, 12/12 Tests, Realtime SSE)
          _buildNovaraMetricsBar(),
          const SizedBox(height: 24),

          // 5. Weekly Habit Matrix / Heatmap 7 ngày
          _buildWeeklyHabitMatrix(context, user),
          const SizedBox(height: 24),

          // 6. Level Progress Bar Card
          _buildLevelCard(user, levelProgress, xpNeeded),
          const SizedBox(height: 24),

          // 7. Priority Quests Header & Actions
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Nhiệm vụ ưu tiên hôm nay',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: Color(0xFF0C1E3C),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99F6E4),
                  foregroundColor: const Color(0xFF082F49),
                  shape: const StadiumBorder(),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => const CreateQuestSheet(),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo mới', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (active.isEmpty)
            const _EmptyHome()
          else
            ...active.map((quest) => QuestCard(quest: quest)),

          const SizedBox(height: 16),

          // 8. Focus Pomodoro Banner Card
          _buildFocusBanner(context),
          const SizedBox(height: 16),

          // 9. Tip Card
          _buildTipCard(),
        ],
      ),
    );
  }

  /// ==============================================================
  /// PHONG CÁCH NOVARA ALPINE GLASS (HÌNH ẢNH MẪU ĐƯỢC CUNG CẤP)
  /// ==============================================================

  /// 1. Novara Alpine Hero Section with Floating Frosted Glass Card & Glowing Neon Chart
  Widget _buildNovaraHeroSection(
    BuildContext context,
    AppUser user,
    AppController controller,
    int activeCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        final leftHero = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Tracking Label Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
              ),
              child: const Text(
                'CLARITY TODAY • A BRIGHTER TOMORROW',
                style: TextStyle(
                  color: Color(0xFF7DD3FC),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mục Tiêu Của Bạn.\nTương Lai Bừng Sáng.',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hệ thống quản lý mục tiêu, rèn luyện thói quen và trợ lý AI Gamification giúp bạn kiến tạo cuộc sống đáng mơ ước.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFCBD5E1),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Primary Mint Pill Button (Novara Book a Consultation)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99F6E4), // Mint ice
                    foregroundColor: const Color(0xFF082F49), // Deep alpine navy
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                    shape: const StadiumBorder(),
                    elevation: 6,
                    shadowColor: const Color(0xFF99F6E4).withValues(alpha: 0.4),
                  ),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => const CreateQuestSheet(),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Bắt đầu Nhiệm vụ',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, letterSpacing: 0.2),
                  ),
                ),
                // Secondary Ghost Glass Pill Button (Novara Watch Video)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => _showExportDialog(context, user, controller),
                  icon: const Icon(Icons.play_circle_outline, size: 18, color: Colors.white),
                  label: const Text(
                    'Xem Thống kê',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Bottom Trust Badges
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const _NovaraTrustBadge(icon: Icons.verified_outlined, text: 'Chuẩn HUTECH'),
                const _NovaraTrustBadge(icon: Icons.shield_outlined, text: 'Bảo mật JWT'),
                const _NovaraTrustBadge(icon: Icons.groups_outlined, text: 'Đồng bộ SSE'),
                if (isWide)
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      '• Progress with Purpose.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF94A3B8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );

        // Right Floating Frosted Glass Card (Novara Total Portfolio Value)
        final floatingGlassCard = Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2644).withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'TỔNG ĐIỂM KINH NGHIỆM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Text(
                      '12 tuần qua ▼',
                      style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedCounter(
                value: user.xp,
                suffix: ' XP',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '↑ 14.8% tuần này',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'so với chu kỳ trước',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Glowing Neon Cyan Bezier Chart
              const NovaraGlowingChart(),
              const SizedBox(height: 16),
              // 3 Sub-metrics pills in a row
              Row(
                children: [
                  Expanded(
                    child: _NovaraSubPill(
                      icon: Icons.trending_up,
                      label: 'Tăng trưởng',
                      value: '+${user.xp % 100} XP',
                      accentColor: const Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showBadges(context, user.badges),
                      child: _NovaraSubPill(
                        icon: Icons.emoji_events_outlined,
                        label: 'Huy hiệu',
                        value: '${user.badges.length} danh hiệu',
                        accentColor: const Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NovaraSubPill(
                      icon: Icons.local_fire_department_outlined,
                      label: 'Kỷ luật',
                      value: '${user.streak} ngày',
                      accentColor: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF07182B), Color(0xFF0B2440), Color(0xFF0F3256)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(26),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 11, child: leftHero),
                    const SizedBox(width: 28),
                    Expanded(flex: 9, child: floatingGlassCard),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftHero,
                    const SizedBox(height: 24),
                    floatingGlassCard,
                  ],
                ),
        );
      },
    );
  }

  /// 2. Novara 5 Pillars Grid (Core Domains)
  Widget _buildNovaraFivePillarsGrid(BuildContext context) {
    const pillars = [
      {
        'title': 'Sức khỏe & Thể thao',
        'sub': 'Cầu lông, bóng đá, chạy bộ duy trì thể lực dồi dào.',
        'icon': Icons.spa_rounded,
        'color': Color(0xFF059669),
        'bg': Color(0xFFECFDF5),
        'xp': '+40 XP',
      },
      {
        'title': 'Học tập & Kỹ năng',
        'sub': 'Chinh phục đồ án Mobile, trau dồi chuyên môn mới.',
        'icon': Icons.pie_chart_outline_rounded,
        'color': Color(0xFF0284C7),
        'bg': Color(0xFFF0F9FF),
        'xp': '+60 XP',
      },
      {
        'title': 'Kỷ luật & Thói quen',
        'sub': 'Duy trì chuỗi streak, rèn tính tự giác hàng ngày.',
        'icon': Icons.shield_outlined,
        'color': Color(0xFF0EA5E9),
        'bg': Color(0xFFE0F2FE),
        'xp': '+30 XP',
      },
      {
        'title': 'Cân bằng Cuộc sống',
        'sub': 'Sắp xếp thời gian khoa học cho gia đình & bản thân.',
        'icon': Icons.home_outlined,
        'color': Color(0xFF6366F1),
        'bg': Color(0xFFEEF2FF),
        'xp': '+25 XP',
      },
      {
        'title': 'Đồng đội & Hợp tác',
        'sub': 'Đồng bộ Realtime SSE, thử thách nhóm cùng tiến bộ.',
        'icon': Icons.groups_outlined,
        'color': Color(0xFF8B5CF6),
        'bg': Color(0xFFF5F3FF),
        'xp': '+50 XP',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TRỤ CỘT RÈN LUYỆN • OUR SERVICES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0284C7),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Định Hướng Mục Tiêu Cho Mọi Giai Đoạn Cuộc Đời.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0C1E3C),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '5 Trụ cột',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF0284C7)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (isWide) {
              return Row(
                children: pillars
                    .map(
                      (p) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _NovaraPillarCard(
                            title: p['title'] as String,
                            sub: p['sub'] as String,
                            icon: p['icon'] as IconData,
                            color: p['color'] as Color,
                            bg: p['bg'] as Color,
                            xp: p['xp'] as String,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: pillars
                  .map(
                    (p) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2 > 160
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth,
                      child: _NovaraPillarCard(
                        title: p['title'] as String,
                        sub: p['sub'] as String,
                        icon: p['icon'] as IconData,
                        color: p['color'] as Color,
                        bg: p['bg'] as Color,
                        xp: p['xp'] as String,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  /// 3. Novara Mountaineer Featured Banner & Testimonial Card
  Widget _buildNovaraFeaturedAndQuote(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 850;

        final mountaineerCard = Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF07182B), Color(0xFF0E2A48)],
            ),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'MORE THAN AN APP • ĐỒNG HÀNH',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7DD3FC),
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Vươn cao hơn',
                      style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Người Bạn Đồng Hành\nTrên Mọi Mục Tiêu.',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Trợ lý AI LifeQuest phân tách mục tiêu lớn thành các bước hành động cụ thể, giúp bạn giữ vững kỷ luật và tự tin về tương lai.',
                style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1), height: 1.45),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99F6E4),
                  foregroundColor: const Color(0xFF082F49),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  shape: const StadiumBorder(),
                  elevation: 4,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vào tab Trợ lý AI để tạo kế hoạch mục tiêu thông minh')),
                  );
                },
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Nhận Tư Vấn AI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ],
          ),
        );

        final quoteCard = Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FD),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFBAE6FD), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '“',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0284C7),
                  height: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'LifeQuest mang lại cho nhóm chúng tôi sự rõ ràng, tự tin và một lộ trình rèn luyện mục tiêu thực sự hiệu quả. Chúng tôi hoàn toàn chủ động trên hành trình chinh phục đồ án.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF0C1E3C),
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '— Nguyễn Viết Lãm (Trưởng nhóm LifeQuest)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF0284C7)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFBAE6FD),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: mountaineerCard),
              const SizedBox(width: 20),
              Expanded(flex: 4, child: quoteCard),
            ],
          );
        }

        return Column(
          children: [
            mountaineerCard,
            const SizedBox(height: 18),
            quoteCard,
          ],
        );
      },
    );
  }

  /// 4. Novara Metrics Bar (4 Stats in a sleek frosted row)
  Widget _buildNovaraMetricsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBAE6FD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          final items = [
            const _NovaraStatItem(icon: Icons.bolt_rounded, value: '100%', label: 'Idempotent XP'),
            const _NovaraStatItem(icon: Icons.star_rounded, value: '4.9/5', label: 'Đánh giá AI Plan'),
            const _NovaraStatItem(icon: Icons.verified_rounded, value: '12/12', label: 'Kiểm thử Đạt chuẩn'),
            const _NovaraStatItem(icon: Icons.wifi_tethering, value: 'Realtime', label: 'Đồng bộ SSE Hub'),
          ];

          if (isWide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.map((it) => Expanded(child: it)).toList(),
            );
          }

          return Wrap(
            runSpacing: 14,
            spacing: 14,
            children: items
                .map((it) => SizedBox(width: (constraints.maxWidth - 14) / 2, child: it))
                .toList(),
          );
        },
      ),
    );
  }

  /// 3. Weekly Habit Matrix / Heatmap 7 ngày (Nova Glass Form)
  Widget _buildWeeklyHabitMatrix(BuildContext context, AppUser user) {
    const days = [
      {'code': 'T2', 'name': 'Th 2', 'done': true},
      {'code': 'T3', 'name': 'Th 3', 'done': true},
      {'code': 'T4', 'name': 'Th 4', 'done': true},
      {'code': 'T5', 'name': 'Th 5', 'done': true},
      {'code': 'T6', 'name': 'Th 6', 'done': true},
      {'code': 'T7', 'name': 'Th 7', 'done': false},
      {'code': 'CN', 'name': 'CN', 'done': false},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month, color: Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'MA TRẬN THÓI QUEN (7 NGÀY)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0C1E3C),
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  'Chuỗi: ${user.streak} ngày 🔥',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((d) {
              final isDone = d['done'] as bool;
              final isToday = d['code'] == 'T4';
              return Column(
                children: [
                  Text(
                    d['name'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                      color: isToday ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF10B981)
                          : (isToday ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isToday
                            ? const Color(0xFF0369A1)
                            : (isDone ? const Color(0xFF059669) : const Color(0xFFE2E8F0)),
                        width: isToday ? 2 : 1,
                      ),
                      boxShadow: isDone || isToday
                          ? [
                              BoxShadow(
                                color: (isDone ? const Color(0xFF10B981) : const Color(0xFF0284C7)).withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : (isToday
                              ? const Icon(Icons.star, color: Colors.white, size: 16)
                              : const Icon(Icons.remove, color: Color(0xFF94A3B8), size: 14)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDone ? 'Đạt' : (isToday ? 'Hôm nay' : 'Chờ'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isDone
                          ? const Color(0xFF059669)
                          : (isToday ? const Color(0xFF0284C7) : const Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.insights, size: 14, color: Color(0xFF0284C7)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tỷ lệ hoàn thành tuần này: 5/7 ngày (71%)',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF0C1E3C)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Level Progress Bar Card (Nova Icy Gradient with Neon ProgressRing & AnimatedCounter)
  Widget _buildLevelCard(AppUser user, double levelProgress, int xpNeeded) {
    final progressPct = (levelProgress.clamp(0.0, 1.0) * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Neon Circular ProgressRing displaying Level & Arc
                ProgressRing(
                  progress: levelProgress,
                  size: 62,
                  strokeWidth: 5.5,
                  startColor: const Color(0xFF99F6E4),
                  endColor: Colors.white,
                  glow: true,
                  centerWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFCD34D), size: 14),
                      Text(
                        '${user.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Cấp độ ${user.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              user.level < 3 ? 'Tân thủ' : (user.level < 6 ? 'Chiến binh' : 'Cao thủ'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$progressPct%',
                            style: const TextStyle(
                              color: Color(0xFFE0F2FE),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          AnimatedCounter(
                            value: user.xp,
                            suffix: ' XP tích lũy',
                            style: const TextStyle(
                              color: Color(0xFFE0F2FE),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              ' • Cần $xpNeeded XP lên cấp',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFE0F2FE),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: levelProgress.clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 5. Focus Pomodoro Banner
  Widget _buildFocusBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.timer_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chế độ Tập trung Pomodoro',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '25 phút tập trung cao độ để bứt phá hiệu suất học tập.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF047857)),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _showFocusDialog(context),
            child: const Text('Bắt đầu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// 6. Tip Card (Nova Glass)
  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAE6FD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.psychology_alt, color: Color(0xFF0284C7), size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mẹo rèn luyện mục tiêu từ LifeQuest',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF0C1E3C),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Chia mục tiêu lớn thành các bước 15–20 phút giúp bạn dễ bắt đầu và duy trì chuỗi streak rực rỡ.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------------------------------------------------
  /// GIAO DIỆN ADMIN THEO PHONG CÁCH 2: DEEP ABYSS OCEAN GLASS (HÌNH 2)
  /// Nền tối sâu thẳm như đáy đại dương, kính mờ tối phát quang Cyan
  /// -------------------------------------------------------------
  Widget _buildAdminDashboard(
    BuildContext context,
    AppUser user,
    AppController controller,
  ) {
    final memberTasks = [
      {
        'title': 'Đánh cầu lông cùng bạn bè',
        'assignee': 'Kỳ',
        'category': 'Sức khỏe',
        'xp': 40,
        'status': 'Đang rèn luyện',
        'color': const Color(0xFF06B6D4),
        'icon': Icons.sports_tennis,
      },
      {
        'title': 'Đá bóng giao hữu cuối tuần',
        'assignee': 'Kỳ',
        'category': 'Sức khỏe',
        'xp': 50,
        'status': 'Sắp diễn ra',
        'color': const Color(0xFF38BDF8),
        'icon': Icons.sports_soccer,
      },
      {
        'title': 'Chạy bộ 5km buổi sáng',
        'assignee': 'Lợi',
        'category': 'Sức khỏe',
        'xp': 30,
        'status': 'Đang thực hiện',
        'color': const Color(0xFFF59E0B),
        'icon': Icons.directions_run,
      },
      {
        'title': 'Học lập trình ứng dụng Flutter',
        'assignee': 'Tuấn',
        'category': 'Học tập',
        'xp': 60,
        'status': 'Đang học tập',
        'color': const Color(0xFFA855F7),
        'icon': Icons.code,
      },
    ];

    return RefreshIndicator(
      onRefresh: () async => await controller.refreshAllData(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [
          // Greeting & Welcome Bar for Admin (Deep Ocean Glass)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào Quản trị viên, ${user.displayName} 🛡️',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Deep Ocean Glass • Bảng điều khiển giám sát hệ thống',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7DD3FC),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B1933),
                  foregroundColor: const Color(0xFF38BDF8),
                  side: BorderSide(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
                ),
                onPressed: () => _showExportDialog(context, user, controller),
                icon: const Icon(Icons.file_upload_outlined, size: 16, color: Color(0xFF38BDF8)),
                label: const Text('Xuất thống kê', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Admin Hub Hero Card (Deep Ocean Abyss Glass - Hình 2)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF07142E), Color(0xFF0E2552)],
              ),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF38BDF8)),
                      ),
                      child: const Icon(Icons.shield, color: Color(0xFF38BDF8), size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trung tâm Quản trị Tối cao',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Vai trò: Quản trị viên hệ thống (Admin)',
                            style: TextStyle(
                              color: Color(0xFFBAE6FD),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF06B6D4)),
                      ),
                      child: const Text(
                        '🟢 TRỰC TUYẾN',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF7DD3FC), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Admin phụ trách kiểm duyệt, quản lý thành viên & nhóm. Admin không tham gia làm nhiệm vụ cá nhân.',
                          style: TextStyle(color: Color(0xFFE0F2FE), fontSize: 12.5, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Admin Overview Metrics (3 Dark Frosted Glass Cards)
          Row(
            children: const [
              Expanded(
                child: _DeepOceanGlassCard(
                  icon: Icons.people_alt_outlined,
                  iconColor: Color(0xFF38BDF8),
                  label: 'THÀNH VIÊN',
                  value: '4',
                  badgeText: 'active',
                  badgeColor: Color(0xFF38BDF8),
                  badgeBg: Color(0xFF072145),
                  subline: 'Kỳ, Lợi, Tuấn, Khách',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _DeepOceanGlassCard(
                  icon: Icons.task_alt_outlined,
                  iconColor: Color(0xFF06B6D4),
                  label: 'QUEST ACTIVE',
                  value: '4',
                  badgeText: 'running',
                  badgeColor: Color(0xFF06B6D4),
                  badgeBg: Color(0xFF062D3E),
                  subline: 'Thể thao & Học tập',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _DeepOceanGlassCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: Color(0xFFF59E0B),
                  label: 'BÁO CÁO VI PHẠM',
                  value: '0',
                  badgeText: 'an toàn',
                  badgeColor: Color(0xFFF59E0B),
                  badgeBg: Color(0xFF352303),
                  subline: 'Hệ thống chuẩn mực',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section Header: Member Task Monitoring
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Giám sát nhiệm vụ thành viên',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1933),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                ),
                child: const Text(
                  '4 đang diễn ra',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Member tasks list for admin oversight (Dark Glass Cards)
          ...memberTasks.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1933).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: (t['color'] as Color).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: (t['color'] as Color).withValues(alpha: 0.4)),
                  ),
                  child: Icon(t['icon'] as IconData, color: t['color'] as Color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Phụ trách: ${t['assignee']}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ),
                          Text(
                            '${t['category']} • +${t['xp']} XP',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF7DD3FC)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071124),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    t['status'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBAE6FD),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showBadges(BuildContext context, List<UserBadge> badges) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bộ sưu tập Huy hiệu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0C1E3C),
                ),
              ),
              const SizedBox(height: 4),
              const Text('Hoàn thành các nhiệm vụ và duy trì chuỗi ngày để mở khóa.'),
              const SizedBox(height: 16),
              if (badges.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Chưa có huy hiệu nào. Hãy hoàn thành nhiệm vụ đầu tiên!'),
                  ),
                )
              else
                ...badges.map(
                  (b) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events, color: Color(0xFFD97706), size: 24),
                      ),
                      title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(b.description),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, AppUser user, AppController controller) {
    final completed = controller.stats?.completed ??
        controller.myQuests.where((q) => q.status == QuestStatus.completed).length;

    final summaryText = '''
BÁO CÁO THÀNH TÍCH RÈN LUYỆN - LIFEQUEST
Người dùng: ${user.displayName} (${user.email})
Cấp độ hiện tại: Level ${user.level}
Tổng điểm kinh nghiệm (XP): ${user.xp} XP
Chuỗi ngày rèn luyện: ${user.streak} ngày liên tiếp (Kỷ lục: ${user.longestStreak} ngày)
Nhiệm vụ đã hoàn thành: $completed quest
Số huy hiệu danh dự: ${user.badges.length} danh hiệu
Ngày xuất báo cáo: ${DateTime.now().toLocal().toString().substring(0, 19)}
''';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment_turned_in, color: Color(0xFF0284C7)),
            ),
            const SizedBox(width: 12),
            const Text('Xuất báo cáo thành tích', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('👤 Thành viên: ${user.displayName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('⚡ Tổng XP: ${user.xp} XP • Cấp độ: Level ${user.level}'),
                  const SizedBox(height: 4),
                  Text('🔥 Chuỗi Streak: ${user.streak} ngày liên tiếp'),
                  const SizedBox(height: 4),
                  Text('🎯 Đã hoàn thành: $completed nhiệm vụ'),
                  const SizedBox(height: 4),
                  Text('🏆 Huy hiệu đạt được: ${user.badges.length}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bạn có thể sao chép bản tóm tắt này để nộp cho câu lạc bộ hoặc lưu trữ.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: summaryText));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép báo cáo thành tích vào bộ nhớ đệm!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Sao chép báo cáo'),
          ),
        ],
      ),
    );
  }

  void _showFocusDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PomodoroDialog(),
    );
  }
}

/// Thẻ số liệu Deep Ocean Glass (Dark Midnight Abyss Glass - Hình 2)
class _DeepOceanGlassCard extends StatelessWidget {
  const _DeepOceanGlassCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBg,
    required this.subline,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBg;
  final String subline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1933).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7DD3FC),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Icon(Icons.north_east, color: Color(0xFF38BDF8), size: 14),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  badgeText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFBAE6FD),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hộp thoại đồng hồ Pomodoro (25 phút) hoạt họa
class _PomodoroDialog extends StatefulWidget {
  const _PomodoroDialog();

  @override
  State<_PomodoroDialog> createState() => _PomodoroDialogState();
}

class _PomodoroDialogState extends State<_PomodoroDialog> {
  static const int totalSeconds = 25 * 60;
  int remainingSeconds = totalSeconds;
  Timer? timer;
  bool isRunning = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void toggleTimer() {
    if (isRunning) {
      timer?.cancel();
      setState(() => isRunning = false);
    } else {
      setState(() => isRunning = true);
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (remainingSeconds > 0) {
          setState(() => remainingSeconds--);
        } else {
          t.cancel();
          setState(() => isRunning = false);
          _onCompleted();
        }
      });
    }
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingSeconds = totalSeconds;
      isRunning = false;
    });
  }

  void _onCompleted() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 Chúc mừng bạn!'),
        content: const Text('Bạn đã hoàn thành trọn vẹn 25 phút tập trung! Bạn nhận thêm +5 XP thưởng rèn luyện.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Tuyệt vời'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = (totalSeconds - remainingSeconds) / totalSeconds;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.timer, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tập trung (25p)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$minutes:$seconds',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -1,
                    ),
                  ),
                  const Text('Tập trung', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Tắt thông báo, tập trung hoàn thành các bước nhiệm vụ.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            timer?.cancel();
            Navigator.pop(context);
          },
          child: const Text('Đóng'),
        ),
        OutlinedButton(
          onPressed: resetTimer,
          child: const Text('Đặt lại'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
          ),
          onPressed: toggleTimer,
          child: Text(isRunning ? 'Tạm dừng' : 'Bắt đầu'),
        ),
      ],
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFBAE6FD)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0284C7).withValues(alpha: 0.08),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFECFDF5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline, size: 36, color: Color(0xFF059669)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Xuất sắc! Bạn đã hoàn thành hết nhiệm vụ hiện tại.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'Hãy nghỉ ngơi hoặc tạo thêm quest mới để tiếp tục nhận XP.',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _NovaraTrustBadge extends StatelessWidget {
  const _NovaraTrustBadge({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF38BDF8)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NovaraSubPill extends StatelessWidget {
  const _NovaraSubPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: accentColor),
          ),
        ],
      ),
    );
  }
}

class _NovaraPillarCard extends StatelessWidget {
  const _NovaraPillarCard({
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    required this.bg,
    required this.xp,
  });

  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final Color bg;
  final String xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  xp,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0C1E3C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF0284C7)),
          ),
        ],
      ),
    );
  }
}

class _NovaraStatItem extends StatelessWidget {
  const _NovaraStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Icon(icon, color: const Color(0xFF0284C7), size: 18),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0C1E3C),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NovaraGlowingChart extends StatelessWidget {
  const NovaraGlowingChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: CustomPaint(
        painter: _NovaraChartPainter(),
      ),
    );
  }
}

class _NovaraChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h * 0.75);
    path.cubicTo(w * 0.2, h * 0.7, w * 0.25, h * 0.85, w * 0.4, h * 0.55);
    path.cubicTo(w * 0.55, h * 0.35, w * 0.65, h * 0.65, w * 0.8, h * 0.3);
    path.cubicTo(w * 0.88, h * 0.15, w * 0.94, h * 0.2, w, h * 0.1);

    // Gradient fill below path
    final fillPath = Path.from(path);
    fillPath.lineTo(w, h);
    fillPath.lineTo(0, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.35),
          const Color(0xFF38BDF8).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // Glowing Line
    final linePaint = Paint()
      ..color = const Color(0xFF67E8F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    // End illuminated dot
    final endPoint = Offset(w, h * 0.1);
    final dotOuter = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.4);
    final dotInner = Paint()..color = Colors.white;

    canvas.drawCircle(endPoint, 7, dotOuter);
    canvas.drawCircle(endPoint, 3.5, dotInner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
