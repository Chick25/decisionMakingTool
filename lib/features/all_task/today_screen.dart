import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Lọc task theo ngày
  List<Task> _getTasksForDay(DateTime day, TaskProvider provider) {
    final allTasks = [
      ...provider.urgentImportant,
      ...provider.notUrgentImportant,
      ...provider.urgentNotImportant,
      ...provider.notUrgentNotImportant
    ];
    return allTasks.where((task) {
      return task.deadline != null &&
          task.deadline!.year == day.year &&
          task.deadline!.month == day.month &&
          task.deadline!.day == day.day;
    }).toList();
  }

  // Xác định Key cho Task để tương tác logic
  String _findKeyForTask(Task task, TaskProvider provider) {
    if (provider.urgentImportant.contains(task)) return TaskService.urgentImportantKey;
    if (provider.notUrgentImportant.contains(task)) return TaskService.notUrgentImportantKey;
    if (provider.urgentNotImportant.contains(task)) return TaskService.urgentNotImportantKey;
    return TaskService.notUrgentNotImportantKey;
  }

  // Lấy màu sắc góc phần tư tương ứng phong cách React
  Color _getCategoryColor(String key) {
    switch (key) {
      case TaskService.urgentImportantKey:
        return const Color(0xFFF43F5E); // Q1 Rose
      case TaskService.notUrgentImportantKey:
        return const Color(0xFF0EA5E9); // Q2 Sky
      case TaskService.urgentNotImportantKey:
        return const Color(0xFFF59E0B); // Q3 Amber
      default:
        return const Color(0xFF10B981); // Q4 Emerald
    }
  }

  String _getQuadrantLabel(String key) {
    switch (key) {
      case TaskService.urgentImportantKey:
        return "Q1";
      case TaskService.notUrgentImportantKey:
        return "Q2";
      case TaskService.urgentNotImportantKey:
        return "Q3";
      default:
        return "Q4";
    }
  }

  // Định nghĩa thứ bằng Tiếng Việt
  String _getVietnameseWeekday(int weekday) {
    const days = {
      1: "Thứ Hai",
      2: "Thứ Ba",
      3: "Thứ Tư",
      4: "Thứ Năm",
      5: "Thứ Sáu",
      6: "Thứ Bảy",
      7: "Chủ Nhật"
    };
    return days[weekday] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Màu nền xám pastel mát mẻ giống React
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasksForSelectedDay = _getTasksForDay(_selectedDay ?? _focusedDay, provider);

          return LayoutBuilder(
            builder: (context, constraints) {
              // Nếu chiều rộng màn hình rộng (Tablet, Web, Desktop) -> Sử dụng 2 cột như React
              if (constraints.maxWidth >= 800) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cột 1: Lịch biểu phong cách tối giản (7 phần)
                      Expanded(
                        flex: 7,
                        child: _buildCalendarCard(provider),
                      ),
                      const SizedBox(width: 24),
                      // Cột 2: Danh sách Agenda bên phải (5 phần)
                      Expanded(
                        flex: 5,
                        child: _buildAgendaCard(provider, tasksForSelectedDay),
                      ),
                    ],
                  ),
                );
              }
              
              // Nếu màn hình hẹp (Mobile) -> Cột đứng nguyên bản
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildCalendarCard(provider),
                      const SizedBox(height: 16),
                      _buildAgendaCard(provider, tasksForSelectedDay),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget xây dựng Lịch biểu cao cấp giống React
  Widget _buildCalendarCard(TaskProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color:Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Lịch biểu
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lịch Trình Công Việc",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Công cụ theo dõi thời hạn",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Widget Lịch
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday, // Tuần bắt đầu từ Thứ 2 giống văn hóa VN
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
              leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF64748B)),
              rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
              weekendStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            
            // Thiết kế giao diện ngày lịch tùy chỉnh
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              defaultTextStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF334155)),
              weekendTextStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFEF4444)),
              outsideDaysVisible: false,
              
              // Kiểu ngày hôm nay (Ouline thanh lịch)
              todayDecoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                shape: BoxShape.circle,
              ),
              todayTextStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),

              // Kiểu ngày được chọn (Solid Indigo cực sang)
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF4F46E5),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // Điểm nhấn quan trọng nhất: Marker hiển thị nhiệm vụ đa sắc Eisenhower dưới ngày
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final dayTasks = _getTasksForDay(date, provider);
                if (dayTasks.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dayTasks.take(4).map((task) {
                      final isCompleted = task.isDone;
                      final key = _findKeyForTask(task, provider);
                      Color dotColor = Colors.grey;
                      if (isCompleted) {
                        dotColor = const Color(0xFF10B981); // Xanh hoàn thành
                      } else {
                        dotColor = _getCategoryColor(key); // Màu góc phần tư tương ứng
                      }
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        width: 4.5,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng chi tiết Agenda ngày bên cạnh giống React
  Widget _buildAgendaCard(TaskProvider provider, List<Task> selectedTasks) {
    final selectedDayText = _selectedDay != null
        ? "${_getVietnameseWeekday(_selectedDay!.weekday)}, ngày ${_selectedDay!.day.toString().padLeft(2, '0')}/${_selectedDay!.month.toString().padLeft(2, '0')}/${_selectedDay!.year}"
        : "";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header của Agenda ngày
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kế hoạch chi tiết ngày",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedDayText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              // Nút thêm nhanh nếu muốn kích hoạt danh mục góc từ calendar screen
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bookmark_added_rounded, color: Color(0xFF4F46E5), size: 16),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1),

          // Danh sách Agenda các việc cần làm ngày
          selectedTasks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_box_outlined,
                            color: Color(0xFFCBD5E1),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Không có công việc nào",
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Hôm nay bạn thảnh thơi hoặc chưa hẹn giờ lên lịch cho tác vụ.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedTasks.length,
                  itemBuilder: (context, index) {
                    final task = selectedTasks[index];
                    final key = _findKeyForTask(task, provider);
                    final categoryColor = _getCategoryColor(key);
                    final label = _getQuadrantLabel(key);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                      ),
                      child: Row(
                        children: [
                          // Checkbox tích hoàn thành trực tiếp bằng provider
                          Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: task.isDone,
                              activeColor: const Color(0xFF10B981),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                provider.toggleDone(key, task);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Tiêu đề & Giờ cụ thể
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: task.isDone ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                if (task.deadline != null) ...[
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, color: Color(0xFF94A3B8), size: 10),
                                      const SizedBox(width: 3),
                                      Text(
                                        "${task.deadline!.hour.toString().padLeft(2, '0')}:${task.deadline!.minute.toString().padLeft(2, '0')}",
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Quadrant Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.inter(
                                color: categoryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Nút xóa trực tiếp bằng provider
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              provider.toggleDone(key, task); // Lấy hoàn thành gốc trước khi thực hiện xóa
                              provider.deleteTask(key, task);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
          
          // Thống kê sơ bộ góc dưới
          const Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tổng số: ${selectedTasks.length} tác vụ",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                "Xong: ${selectedTasks.where((t) => t.isDone).length}",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}