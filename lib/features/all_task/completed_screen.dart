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

// Lớp tiện ích giữ thông tin gợi ý từ huấn luyện viên năng suất
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

  // Tìm Key nguyên bản tương thích với cơ sở dữ liệu và Provider
  String _findKeyForTask(Task task, TaskProvider provider) {
    if (provider.urgentImportant.contains(task)) return TaskService.urgentImportantKey;
    if (provider.notUrgentImportant.contains(task)) return TaskService.notUrgentImportantKey;
    if (provider.urgentNotImportant.contains(task)) return TaskService.urgentNotImportantKey;
    return TaskService.notUrgentNotImportantKey;
  }

  // Khởi tạo các gợi ý định hướng thông minh đồng bộ logic cũ
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

    // 1. Phân tích tồn đọng Q1
    final pendingQ1 = q1Total - q1Completed;
    if (pendingQ1 > 1) {
      list.add(CoachInsight(
        type: 'warn',
        title: 'LƯU TÂM',
        text: 'Bạn đang tồn đọng $pendingQ1 việc cực kỳ Khẩn cấp & Quan trọng (Q1). Hãy dành sự tập trung tối đa để dứt điểm các mục này đầu tiên để phòng tránh khủng hoảng nhé!',
        icon: Icons.gpp_maybe_rounded,
      ));
    }

    // 2. Đánh giá mật độ công việc vùng Q2
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

    // 3. Phân tích gánh nặng xao nhãng Q3
    final pendingQ3 = q3Total - q3Completed;
    if (pendingQ3 >= 2) {
      list.add(CoachInsight(
        type: 'warn',
        title: 'LƯU TÂM',
        text: 'Hiện đang có $pendingQ3 công việc Khẩn cấp nhưng Ít quan trọng (Q3). Đôi khi đây chỉ là các việc xen ngang gây xao nhãng. Hãy cân nhắc gom nhóm làm nhanh hoặc ủy quyền.',
        icon: Icons.gpp_maybe_rounded,
      ));
    }

    // 4. Xem xét lãng phí thời gian Q4
    if (q4Total >= 3) {
      list.add(CoachInsight(
        type: 'warn',
        title: 'LƯU TÂM',
        text: 'Bạn ghi nhận khá nhiều việc trong nhóm Q4 ($q4Total việc). Hãy can đảm gạch bớt phần lớn công việc ở nhóm này để giải phóng tâm trí và quỹ thời gian nhé!',
        icon: Icons.lightbulb_outline_rounded,
      ));
    }

    // 5. Tỉ lệ hoàn thiện xuất sắc
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
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Đồng bộ nền mượt với Scaffold mẹ ở main.dart
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
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

          final int q1Total = provider.urgentImportant.length;
          final int q1Completed = provider.urgentImportant.where((t) => t.isDone).length;

          final int q2Total = provider.notUrgentImportant.length;
          final int q2Completed = provider.notUrgentImportant.where((t) => t.isDone).length;

          final int q3Total = provider.urgentNotImportant.length;
          final int q3Completed = provider.urgentNotImportant.where((t) => t.isDone).length;

          final int q4Total = provider.notUrgentNotImportant.length;
          final int q4Completed = provider.notUrgentNotImportant.where((t) => t.isDone).length;

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
              // 1. HEADER KHÔNG CHỒNG CHÉO (SliverToBoxAdapter thay thế cho SliverAppBar lỗi vỡ chữ)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    children: [
                      // Thanh điều hướng trên cùng phẳng kiểu Nordic (Xây dựng an toàn)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Nút tròn quay lại tinh xảo bảo vệ bằng container chống lỗi pop
                          InkWell(
                            onTap: () => Navigator.maybePop(context),
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.dividerColor,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 15,
                                color: isDark ? Colors.white70 : const Color(0xFF334155),
                              ),
                            ),
                          ),
                          
                          // Tiêu đề căn trung tâm chuẩn mượt
                          Text(
                            "Đã Hoàn Thành",
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          
                          // Widget trống bổ trợ cân đối khoảng cách dòng đều đặn
                          const SizedBox(width: 42),
                        ],
                      ),
                      
                      const SizedBox(height: 20),

                      // Banner chào mừng thiết kế bóng phẳng (Flat Accent Banner)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9).withOpacity(0.55),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_user_rounded, 
                                color: Color(0xFF4F46E5), 
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Bạn đã hoàn thành $completed tác vụ",
                              style: GoogleFonts.inter(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                fontSize: 13, 
                                // fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Thẻ TIẾN TRÌNH HOÀN THIỆN (Radial Circular Progress)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: theme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "TIẾN TRÌNH HOÀN THIỆN",
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodySmall?.color,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Vòng hiển thị tiến độ Radial mượt mà như SVG
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 110,
                                height: 110,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 7,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? const Color(0xFF161616) : const Color(0xFFF1F5F9),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 110,
                                height: 110,
                                child: CircularProgressIndicator(
                                  value: rate / 100,
                                  strokeWidth: 7,
                                  strokeCap: StrokeCap.round,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${rate.round()}%",
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: theme.textTheme.titleLarge?.color,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    "Xong",
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodySmall?.color,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(height: 1, color: theme.dividerColor),
                        const SizedBox(height: 18),
                        // Ba mốc hiển thị chi tiết các chỉ số
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn("Tổng việc", "$total", isDark),
                            Container(width: 1, height: 28, color: theme.dividerColor),
                            _buildStatColumn("Đã xong", "$completed", isDark, valueColor: const Color(0xFF10B981)),
                            Container(width: 1, height: 28, color: theme.dividerColor),
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
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: theme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "PHÂN PHỐI THEO GÓC PHẦN TƯ",
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodySmall?.color,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Chuyên gia thời gian đề xuất tập trung 60-70% tổng lực tinh thần vào Q2 (Quan trọng nhưng Không khẩn cấp).",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: theme.textTheme.bodySmall?.color,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _buildQuadrantRow(
                          title: "Q1: Khẩn và Quan trọng",
                          completed: q1Completed,
                          total: q1Total,
                          densityPercent: total > 0 ? (q1Total / total) : 0,
                          completionPercent: q1Total > 0 ? (q1Completed / q1Total) : 0,
                          color: const Color(0xFFF43F5E),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildQuadrantRow(
                          title: "Q2: Kế hoạch lâu dài",
                          completed: q2Completed,
                          total: q2Total,
                          densityPercent: total > 0 ? (q2Total / total) : 0,
                          completionPercent: q2Total > 0 ? (q2Completed / q2Total) : 0,
                          color: const Color(0xFF0EA5E9),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildQuadrantRow(
                          title: "Q3: Gây xao nhãng",
                          completed: q3Completed,
                          total: q3Total,
                          densityPercent: total > 0 ? (q3Total / total) : 0,
                          completionPercent: q3Total > 0 ? (q3Completed / q3Total) : 0,
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
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
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.5) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4F46E5), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "GỢI Ý HUẤN LUYỆN VIÊN NĂNG SUẤT",
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
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

              // Tiêu đề phân mục dưới
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 2),
                  child: Text(
                    "DANH SÁCH NHIỆM VỤ ĐÃ HOÀN THÀNH",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // 5. Bộ lọc dạng viên nang Sleek Tabs nổi mềm mại (Capsule Tab Buttons)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161616) : const Color(0xFFF1F5F9),
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
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 8.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.cardColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getFilterIcon(f),
                                    size: 14,
                                    color: isSelected
                                        ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color),
                                  
                                  const SizedBox(width: 6),
                                  Text(
                                    _getFilterName(f),
                                    style: GoogleFonts.inter(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      fontSize: 12,
                                      color: isSelected
                                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
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

              // 6. Danh sách tác vụ hiển thị dưới dạng Slate Cards phẳng thanh mảnh
              filteredTasks.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.playlist_add_check_rounded, 
                                size: 42, 
                                color: isDark ? const Color(0xFF252525) : const Color(0xFFCBD5E1),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Không tìm thấy việc nào hoàn tất cả",
                                style: GoogleFonts.inter(
                                  fontSize: 13, 
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF555555) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = filteredTasks[index];
                          final key = _findKeyForTask(task, provider);
                          return _buildSleekTaskCard(context, task, key, provider, isDark);
                        },
                        childCount: filteredTasks.length,
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  // Cột hiển thị số liệu nhỏ gọn, đồng bộ visual
  Widget _buildStatColumn(String label, String value, bool isDark, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: valueColor ?? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A)),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  // Dòng hiển thị Dual Ma Trận Process Progress Bar chuẩn React (Đã chuẩn hóa công thức tỷ lệ 100%)
  Widget _buildQuadrantRow({
    required String title,
    required int completed,
    required int total,
    required double densityPercent,
    required double completionPercent,
    required Color color,
    required bool isDark,
  }) {
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
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
            Text(
              "$completed/$total mục (${(densityPercent * 100).round()}% lượng)",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 10.5,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Thước đo hai mức diện tích mờ bao phủ
        Container(
          width: double.infinity,
          height: 20,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161616) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          child: Stack(
            children: [
              // 1. Phủ mờ mật độ số lượng tổng thể (Density shadow layer)
              FractionallySizedBox(
                widthFactor: densityPercent.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              // 2. Tiến trình dứt điểm hoàn thành việc thật thụ (Chuyển đổi hoàn hảo 100%)
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
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
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

  // Thẻ hỗ trợ của Productivity Coach chuẩn phong thái React
  Widget _buildInsightCard(CoachInsight insight, bool isDark) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final Color tagBgColor;
    final String tagLabel = insight.title;

    if (insight.type == 'success') {
      bgColor = isDark ? const Color(0xFF064E3B).withOpacity(0.12) : const Color(0xFFECFDF5);
      borderColor = isDark ? const Color(0xFF059669).withOpacity(0.2) : const Color(0xFFA7F3D0);
      textColor = isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46);
      tagBgColor = isDark ? const Color(0xFF047857) : const Color(0xFF34D399).withOpacity(0.2);
    } else if (insight.type == 'warn') {
      bgColor = isDark ? const Color(0xFF78350F).withOpacity(0.1) : const Color(0xFFFFFBEB);
      borderColor = isDark ? const Color(0xFFD97706).withOpacity(0.15) : const Color(0xFFFEF3C7);
      textColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
      tagBgColor = isDark ? const Color(0xFFB45309) : const Color(0xFFFBBF24).withOpacity(0.2);
    } else {
      bgColor = isDark ? const Color(0xFF161616) : Colors.white;
      borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0);
      textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
      tagBgColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFCBD5E1).withOpacity(0.35);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insight.icon,
              color: insight.type == 'success'
                  ? const Color(0xFF10B981)
                  : insight.type == 'warn'
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF4F46E5),
              size: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
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

  // Thẻ Task Card tinh tế tuyệt đẹp chuẩn Flat Nordic style
  Widget _buildSleekTaskCard(BuildContext context, Task task, String key, TaskProvider provider, bool isDark) {
    final Map<String, dynamic> qDesign = _getQuadrantDesign(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chỉ thị màu mỏng dạng dọc ở bên trái hệt như TaskCard của React 
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: qDesign['color'] as Color,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Trạng thái nút check tích xanh nhạt tối giản
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(isDark ? 0.12 : 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded, 
                          color: Color(0xFF10B981), 
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tiêu đề cùng thời gian dãn dòng mượt
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              task.title,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600 ?? FontWeight.w500,
                                color: isDark ? const Color(0xFF555555) : const Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: (qDesign['color'] as Color).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    qDesign['label'] as String,
                                    style: GoogleFonts.inter(
                                      color: qDesign['color'] as Color,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 8.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.event_note_rounded, 
                                  size: 11, 
                                  color: isDark ? const Color(0xFF444444) : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  "${task.createdAt.day}/${task.createdAt.month}",
                                  style: GoogleFonts.inter(
                                    color: isDark ? const Color(0xFF555555) : const Color(0xFF94A3B8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Nút xóa công việc
                      IconButton(
                        splashRadius: 16,
                        icon: const Icon(
                          Icons.delete_outline_rounded, 
                          color: Color(0xFFEF4444),
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

  // Phục vụ cấu hình icon bộ lọc viên nang
  IconData _getFilterIcon(CompletedFilter filter) {
    switch (filter) {
      case CompletedFilter.all: return Icons.all_inclusive_rounded;
      case CompletedFilter.urgent: return Icons.offline_bolt_rounded;
      case CompletedFilter.notUrgent: return Icons.spa_rounded;
    }
  }

  // Tên hiển thị các bộ lọc
  String _getFilterName(CompletedFilter filter) {
    switch (filter) {
      case CompletedFilter.all: return "Tất cả";
      case CompletedFilter.urgent: return "Khẩn cấp";
      case CompletedFilter.notUrgent: return "Thư thả";
    }
  }

  // Bộ preset chuẩn hóa màu sắc từ React
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