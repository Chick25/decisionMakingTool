import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

enum CompletedFilter { all, urgent, notUrgent }

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

// Lớp tiện ích để giữ dữ liệu gợi ý của huấn luyện viên năng suất
class CoachInsight {
  final String type; // 'success', 'warn', 'neutral'
  final String title; // 'Điểm sáng', 'Lưu tâm', 'Lời khuyên'
  final String text;
  final IconData icon;

  CoachInsight({
    required this.type,
    required this.title,
    required this.text,
    required this.icon,
  });
}

class _CompletedScreenState extends State<CompletedScreen> {
  CompletedFilter _filter = CompletedFilter.all;

  // Xác định Key nguyên bản để tương tác với cơ sở dữ liệu và Provider
  String _findKeyForTask(Task task, TaskProvider provider) {
    if (provider.urgentImportant.contains(task)) return TaskService.urgentImportantKey;
    if (provider.notUrgentImportant.contains(task)) return TaskService.notUrgentImportantKey;
    if (provider.urgentNotImportant.contains(task)) return TaskService.urgentNotImportantKey;
    return TaskService.notUrgentNotImportantKey;
  }

  // Khởi tạo các gợi ý định hướng thông minh dựa trên phân bổ số liệu thực tế
  List<CoachInsight> _generateInsights({
    required int total,
    required double rate,
    required int q1Total,
    required int q1Completed,
    required int q2Total,
    required int q2Completed,
    required int q3Total,
    required int q3Completed,
    required int q4Total,
    required int q4Completed,
  }) {
    final List<CoachInsight> list = [];

    if (total == 0) {
      list.add(CoachInsight(
        type: 'neutral',
        title: 'LỜI KHUYÊN',
        text: 'Vui lòng thêm một số mục công việc để bắt đầu nhận phân tích hiệu suất.',
        icon: Icons.directions_walk_rounded,
      ));
      return list;
    }

    // 1. Phân tích tồn đọng Q1 (Khẩn cấp & Quan trọng)
    final pendingQ1 = q1Total - q1Completed;
    if (pendingQ1 > 1) {
      list.add(CoachInsight(
        type: 'warn',
        title: 'LƯU TÂM',
        text: 'Bạn đang tồn đọng $pendingQ1 việc cực kỳ Khẩn cấp & Quan trọng (Q1). Hãy dành sự tập trung tối đa để dứt điểm các mục này đầu tiên để phòng tránh khủng hoảng nhé!',
        icon: Icons.gpp_maybe_rounded,
      ));
    }

    // 2. Đánh giá mật độ công việc vùng Q2 (Cốt lõi cải tiến năng lực dài hạn)
    if (q2Total >= 2) {
      list.add(CoachInsight(
        type: 'success',
        title: 'ĐIỂM SÁNG',
        text: 'Thật tuyệt vời! Bạn có $q2Total công việc thuộc nhóm Kế hoạch dài hạn (Q2). Đây là vùng \'Không khẩn cấp nhưng Quan trọng\' - cốt lõi để bản thân bạn cải tiến chất lượng lâu dài.',
        icon: Icons.emoji_events_rounded,
      ));
    } else {
      list.add(CoachInsight(
        type: 'neutral',
        title: 'LỜI KHUYÊN',
        text: 'Nên lập kế hoạch thêm cho góc phần tư Q2 (Công việc quan trọng nhưng không khẩn cấp) để xây dựng sự kỷ luật và giảm áp lực về lâu dài.',
        icon: Icons.auto_awesome_rounded,
      ));
    }

    // 3. Phân tích các việc xao nhãng Q3 (Khẩn cấp nhưng ít quan trọng)
    final pendingQ3 = q3Total - q3Completed;
    if (pendingQ3 >= 2) {
      list.add(CoachInsight(
        type: 'warn',
        title: 'LƯU TÂM',
        text: 'Hiện đang có $pendingQ3 công việc Khẩn cấp nhưng Ít quan trọng (Q3). Đôi khi đây chỉ là các việc xen ngang gây xao nhãng. Hãy cân nhắc gom nhóm làm nhanh hoặc ủy quyền nhé.',
        icon: Icons.gpp_maybe_rounded,
      ));
    }

    // 4. Xem xét lãng phí thời gian Q4 (Ít giá trị)
    if (q4Total >= 3) {
      list.add(CoachInsight(
        type: 'warn',
        title: 'LƯU TÂM',
        text: 'Bạn ghi nhận khá nhiều việc trong nhóm Q4 ($q4Total việc). Hãy can đảm gạch bớt phần lớn công việc ở nhóm này để giải phóng tâm trí và quỹ thời gian vàng ngọc nhé!',
        icon: Icons.lightbulb_outline_rounded,
      ));
    }

    // 5. Khen thưởng tỷ lệ hoàn thiện xuất sắc
    if (rate >= 75) {
      list.add(CoachInsight(
        type: 'success',
        title: 'ĐIỂM SÁNG',
        text: 'Hiệu suất xuất sắc! Bạn đã giải quyết thành công ${rate.round()}% khối lượng công việc đặt ra. Hãy giữ nhịp độ lý tưởng này nhé!',
        icon: Icons.check_circle_rounded,
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          // Lấy danh sách nhiệm vụ đã hoàn thiện theo logic của bạn
          final completedTasks = [
            ...provider.urgentImportant,
            ...provider.notUrgentImportant,
            ...provider.urgentNotImportant,
            ...provider.notUrgentNotImportant
          ].where((task) => task.isDone).toList();

          final filteredTasks = completedTasks.where((task) {
            if (_filter == CompletedFilter.all) return true;
            bool isUrgent = provider.urgentImportant.contains(task) || 
                            provider.urgentNotImportant.contains(task);
            return _filter == CompletedFilter.urgent ? isUrgent : !isUrgent;
          }).toList();

          // Tính toán số liệu thống kê như bên React
          final allTasks = [
            ...provider.urgentImportant,
            ...provider.notUrgentImportant,
            ...provider.urgentNotImportant,
            ...provider.notUrgentNotImportant
          ];

          final int total = allTasks.length;
          final int completed = allTasks.where((t) => t.isDone).length;
          final int pending = total - completed;
          final double rate = total > 0 ? (completed / total) * 100 : 0.0;

          // Phân phối theo từng Góc phần tư
          final int q1Total = provider.urgentImportant.length;
          final int q1Completed = provider.urgentImportant.where((t) => t.isDone).length;

          final int q2Total = provider.notUrgentImportant.length;
          final int q2Completed = provider.notUrgentImportant.where((t) => t.isDone).length;

          final int q3Total = provider.urgentNotImportant.length;
          final int q3Completed = provider.urgentNotImportant.where((t) => t.isDone).length;

          final int q4Total = provider.notUrgentNotImportant.length;
          final int q4Completed = provider.notUrgentNotImportant.where((t) => t.isDone).length;

          // Nhận các gợi ý từ Huấn luyện viên
          final insights = _generateInsights(
            total: total,
            rate: rate,
            q1Total: q1Total,
            q1Completed: q1Completed,
            q2Total: q2Total,
            q2Completed: q2Completed,
            q3Total: q3Total,
            q3Completed: q3Completed,
            q4Total: q4Total,
            q4Completed: q4Completed,
          );

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header nghệ thuật đặc thù
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF6366F1),
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.15,
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: Text(
                    "Đã Hoàn Thành",
                    style: GoogleFonts.philosopher(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 0.5,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                              ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
                              : [const Color(0xFF4F46E5), const Color(0xFF06B6D4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -15,
                        bottom: 15,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.03),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_rounded, 
                                color: Colors.white, 
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Tích lũy: $completed nhiệm vụ hoàn thành",
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.85), 
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Thẻ hiển thị TIẾN TRÌNH HOÀN THIỆN (Radial Circular Progress)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "TIẾN TRÌNH HOÀN THIỆN",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Circular Progress Stack mượt mà
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 130,
                                height: 130,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 10,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                height: 130,
                                child: CircularProgressIndicator(
                                  value: rate / 100,
                                  strokeWidth: 10,
                                  strokeCap: StrokeCap.round,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${rate.round()}%",
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "ĐÃ XONG",
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF94A3B8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 18),
                        // Ba mốc hiển thị chi tiết chỉ số
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn("Tổng việc", "$total", isDark),
                            Container(width: 1, height: 32, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            _buildStatColumn("Đã xong", "$completed", isDark, valueColor: const Color(0xFF10B981)),
                            Container(width: 1, height: 32, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            _buildStatColumn("Chờ làm", "$pending", isDark, valueColor: const Color(0xFFF59E0B)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Thẻ PHÂN PHỐI THEO GÓC PHẦN TƯ (Dual Process Meters)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "PHÂN PHỐI THEO GÓC PHẦN TƯ",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Chuyên gia thời gian tối ưu phân bổ 60-70% tổng lực của mindmap vào góc phần tư Q2 (Quan trọng nhưng Không khẩn cấp).",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildQuadrantRow(
                          title: "Q1: Khẩn cấp & Quan trọng",
                          completed: q1Completed,
                          total: q1Total,
                          densityPercent: total > 0 ? (q1Total / total) : 0,
                          completionPercent: q1Total > 0 ? (q1Completed / q1Total) : 0,
                          color: const Color(0xFFF43F5E),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                        _buildQuadrantRow(
                          title: "Q2: Kế hoạch lâu dài",
                          completed: q2Completed,
                          total: q2Total,
                          densityPercent: total > 0 ? (q2Total / total) : 0,
                          completionPercent: q2Total > 0 ? (q2Completed / q2Total) : 0,
                          color: const Color(0xFF0EA5E9),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                        _buildQuadrantRow(
                          title: "Q3: Gây xao nhãng",
                          completed: q3Completed,
                          total: q3Total,
                          densityPercent: total > 0 ? (q3Total / total) : 0,
                          completionPercent: q3Total > 0 ? (q3Completed / q3Total) : 0,
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                        _buildQuadrantRow(
                          title: "Q4: Ít giá trị",
                          completed: q4Completed,
                          total: q4Total,
                          densityPercent: total > 0 ? (q4Total / total) : 0,
                          completionPercent: q4Total > 0 ? (q4Completed / q4Total) : 0,
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. GỢI Ý HUẤN LUYỆN VIÊN NĂNG SUẤT (Coaching Smart Insights)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withOpacity(0.4) : const Color(0xFFF1F5F9).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155).withOpacity(0.3) : const Color(0xFFE2E8F0).withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "GỢI Ý HUẤN LUYỆN VIÊN NĂNG SUẤT",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: insights.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildInsightCard(insights[index], isDark);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tiêu đề vùng tìm kiếm kiểm soát nhiệm vụ
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        "DANH SÁCH NHIỆM VỤ ĐÃ HOÀN THÀNH",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Bộ lọc dạng viên nang Sleek Tabs nổi mềm mại (Capsule Tab Buttons)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: CompletedFilter.values.map((f) {
                        final isSelected = _filter == f;
                        return Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _filter = f),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF475569) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getFilterIcon(f),
                                    size: 15,
                                    color: isSelected
                                        ? (isDark ? Colors.white : const Color(0xFF4F46E5))
                                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _getFilterName(f),
                                    style: GoogleFonts.inter(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      fontSize: 12,
                                      color: isSelected
                                          ? (isDark ? Colors.white : const Color(0xFF1E293B))
                                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // 6. Danh sách tác vụ hiển thị dưới dạng Slate Cards mượt mà
              filteredTasks.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checklist_rounded, 
                              size: 48, 
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Không tìm thấy nhiệm vụ nào phù hợp",
                              style: GoogleFonts.inter(
                                fontSize: 13, 
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = filteredTasks[index];
                            final key = _findKeyForTask(task, provider);
                            return _buildSleekTaskCard(context, task, key, provider, isDark);
                          },
                          childCount: filteredTasks.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  // Cột hiển thị số liệu nhỏ gọn, trực quan
  Widget _buildStatColumn(String label, String value, bool isDark, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  // Dòng hiển thị Dual Matrix Process Progress Bar
  Widget _buildQuadrantRow({
    required String title,
    required int completed,
    required int total,
    required double densityPercent,
    required double completionPercent,
    required Color color,
    required bool isDark,
  }) {
    final densityText = "${(densityPercent * 100).round()}% mật độ";
    final isAnyTask = total > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
            Text(
              "$completed/$total việc ($densityText)",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Bộ hiển thị dual levels: Shadow Density bọc lót và cột màu tiến tiến trình thật thụ
        Container(
          width: double.infinity,
          height: 22,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF334155).withOpacity(0.3) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Stack(
            children: [
              // 1. Phủ mờ mật độ (Density shadow layer)
              FractionallySizedBox(
                widthFactor: densityPercent.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              // 2. Thước tiến trình công việc đã gặt hái (Completion overlay)
              if (isAnyTask)
                FractionallySizedBox(
                  widthFactor: completionPercent.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.85)],
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: completionPercent >= 0.20
                        ? Text(
                            "${(completionPercent * 100).round()}%",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Thẻ hỗ trợ của Productivity Coach
  Widget _buildInsightCard(CoachInsight insight, bool isDark) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final Color tagBgColor;
    final String tagLabel = insight.title;

    if (insight.type == 'success') {
      bgColor = isDark ? const Color(0xFF064E3B).withOpacity(0.2) : const Color(0xFFECFDF5);
      borderColor = isDark ? const Color(0xFF059669).withOpacity(0.3) : const Color(0xFFA7F3D0);
      textColor = isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46);
      tagBgColor = isDark ? const Color(0xFF047857) : const Color(0xFF34D399).withOpacity(0.25);
    } else if (insight.type == 'warn') {
      bgColor = isDark ? const Color(0xFF78350F).withOpacity(0.15) : const Color(0xFFFFFBEB);
      borderColor = isDark ? const Color(0xFFD97706).withOpacity(0.2) : const Color(0xFFFEF3C7);
      textColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
      tagBgColor = isDark ? const Color(0xFFB45309) : const Color(0xFFFBBF24).withOpacity(0.25);
    } else {
      bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
      borderColor = isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFE2E8F0);
      textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
      tagBgColor = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1).withOpacity(0.4);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              insight.icon,
              color: insight.type == 'success'
                  ? const Color(0xFF10B981)
                  : insight.type == 'warn'
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF6366F1),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tagLabel,
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: insight.type == 'success'
                          ? (isDark ? Colors.white : const Color(0xFF065F46))
                          : insight.type == 'warn'
                              ? (isDark ? Colors.white : const Color(0xFF92400E))
                              : (isDark ? Colors.white : const Color(0xFF475569)),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  insight.text,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Thẻ Task Card tinh tế của phong cách thiết kế Nordic
  Widget _buildSleekTaskCard(BuildContext context, Task task, String key, TaskProvider provider, bool isDark) {
    final Map<String, dynamic> qDesign = _getQuadrantDesign(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh phân tích loại ma trận góc trái cách điệu
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: qDesign['color'] as Color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Vòng hoàn tất
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(isDark ? 0.15 : 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded, 
                          color: Color(0xFF10B981), 
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Toàn bộ thông tin chữ và ngày tháng
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              task.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (qDesign['color'] as Color).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    qDesign['label'] as String,
                                    style: GoogleFonts.inter(
                                      color: qDesign['color'] as Color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.event_available_rounded, 
                                  size: 12, 
                                  color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  "${task.createdAt.day}/${task.createdAt.month}",
                                  style: GoogleFonts.inter(
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Nút xóa nhiệm vụ đơn sắc thời trang
                      IconButton(
                        splashRadius: 18,
                        icon: Icon(
                          Icons.delete_outline_rounded, 
                          color: isDark ? const Color(0xFFEF4444) : const Color(0xFFF43F5E),
                          size: 18,
                        ),
                        onPressed: () => provider.deleteTask(key, task),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Trả về Icon cho từng bộ lọc
  IconData _getFilterIcon(CompletedFilter filter) {
    switch (filter) {
      case CompletedFilter.all: return Icons.all_inclusive_rounded;
      case CompletedFilter.urgent: return Icons.bolt_rounded;
      case CompletedFilter.notUrgent: return Icons.spa_rounded;
    }
  }

  // Trả về Tên bộ lọc
  String _getFilterName(CompletedFilter filter) {
    switch (filter) {
      case CompletedFilter.all: return "Tất cả";
      case CompletedFilter.urgent: return "Khẩn cấp";
      case CompletedFilter.notUrgent: return "Thư thả";
    }
  }

  // Trả về màu sắc pastel và nhãn dán tương thích từ preset
  Map<String, dynamic> _getQuadrantDesign(String key) {
    switch (key) {
      case TaskService.urgentImportantKey:
        return {
          'color': const Color(0xFFF43F5E), // Rose 500
          'label': 'Q1',
        };
      case TaskService.notUrgentImportantKey:
        return {
          'color': const Color(0xFF0EA5E9), // Sky 500
          'label': 'Q2',
        };
      case TaskService.urgentNotImportantKey:
        return {
          'color': const Color(0xFFF59E0B), // Amber 500
          'label': 'Q3',
        };
      default:
        return {
          'color': const Color(0xFF10B981), // Emerald 500
          'label': 'Q4',
        };
    }
  }
}