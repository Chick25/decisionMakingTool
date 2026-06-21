
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/services/task_service.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import 'package:fl_chart/fl_chart.dart';

class AllTaskScreen extends StatefulWidget {
  final List urgentImportant;
  final List notUrgentImportant;
  final List urgentNotImportant;
  final List notUrgentNotImportant;

  const AllTaskScreen({
    super.key,
    required this.urgentImportant,
    required this.notUrgentImportant,
    required this.urgentNotImportant,
    required this.notUrgentNotImportant,
  });

  @override
  State<AllTaskScreen> createState() => _AllTaskScreenState();
}

class _AllTaskScreenState extends State<AllTaskScreen> {
  int? selectedIndex;
  int? tappedIndex;
  bool isExpended = false;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    final allTasks = [
      ...taskProvider.urgentImportant,
      ...taskProvider.notUrgentImportant,
      ...taskProvider.urgentNotImportant,
      ...taskProvider.notUrgentNotImportant,
    ];

    allTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Slate 100
      body: Stack(
        children: [
          // Bố cục danh sách trượt bên phải
          _buildTaskList(allTasks, taskProvider),
          // Biểu đồ Fl_Chart tuyệt đẹp đặt ở bên trái
          _buildPieChart(taskProvider),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> allTasks, TaskProvider taskProvider) {
    List<Task> currentTasks;

    if (isExpended && tappedIndex != null) {
      if (tappedIndex == 0) {
        currentTasks = [...taskProvider.urgentImportant];
      } else if (tappedIndex == 1) {
        currentTasks = [...taskProvider.notUrgentImportant];
      } else if (tappedIndex == 2) {
        currentTasks = [...taskProvider.urgentNotImportant];
      } else if (tappedIndex == 3) {
        currentTasks = [...taskProvider.notUrgentNotImportant];
      } else {
        currentTasks = [];
      }
    } else {
      currentTasks = [...allTasks];
    }

    currentTasks.sort((a, b) {
      if (a.deadline == null && b.deadline != null) return 1;
      if (a.deadline != null && b.deadline == null) return -1;
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return AnimatedOpacity(
      opacity: isExpended ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      child: Padding(
        padding: const EdgeInsets.only(left: 420, top: 24, right: 24, bottom: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.02),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: currentTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 64,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Danh sách này trống',
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: currentTasks.length,
                  itemBuilder: (context, index) {
                    final task = currentTasks[index];
                    return Card(
                      key: ValueKey('list_${task.id}_$tappedIndex'),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                      color: Theme.of(context).cardColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Checkbox(
                          value: task.isDone,
                          activeColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (value) {
                            taskProvider.toggleDone(_getTaskKey(task), task);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                            color: task.isDone ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: task.deadline != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Ngày hết hạn: ${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                ),
                              )
                            : null,
                        trailing: IconButton(
                          onPressed: () {
                            taskProvider.deleteTask(_getTaskKey(task), task);
                          },
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildPieChart(TaskProvider taskProvider) {
    final sections = [
      taskProvider.urgentImportant.length.toDouble(),
      taskProvider.notUrgentImportant.length.toDouble(),
      taskProvider.urgentNotImportant.length.toDouble(),
      taskProvider.notUrgentNotImportant.length.toDouble(),
    ];

    // Sử dụng mã màu đồng điệu với Sleek interface (Red, Cyan, Emerald, Amber)
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      top: 60,
      left: isExpended ? 40 : (MediaQuery.of(context).size.width / 2) - 130,
      child: Column(
        children: [
          SizedBox(
            width: 320,
            height: 320,
            child: PieChart(
              PieChartData(
                sectionsSpace: 6,
                centerSpaceRadius: 52,
                sections: List.generate(4, (i) {
                  final isTouched = selectedIndex == i;
                  final double radius = isTouched ? 115 : 95;
                  return PieChartSectionData(
                    value: sections[i] == 0 ? 0.1 : sections[i],
                    color: colors[i],
                    title: sections[i].toInt() > 0 ? sections[i].toInt().toString() : '',
                    radius: radius,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                    final int? currentIndex = response?.touchedSection?.touchedSectionIndex;
                    if (event is FlPointerHoverEvent || event is FlLongPressMoveUpdate) {
                      setState(() {
                        selectedIndex = currentIndex;
                      });
                    } else if (event is FlTapUpEvent) {
                      setState(() {
                        if (currentIndex == null || (tappedIndex == currentIndex && isExpended)) {
                          isExpended = false;
                          tappedIndex = null;
                        } else {
                          tappedIndex = currentIndex;
                          isExpended = true;
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Bảng chú giải chú thích (Legend indicators)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(colors[0], 'Khẩn cấp & Quan trọng (Q1)'),
                const SizedBox(height: 6),
                _buildLegendItem(colors[1], 'Không khẩn nhưng Quan trọng (Q2)'),
                const SizedBox(height: 6),
                _buildLegendItem(colors[2], 'Khẩn nhưng Không quan trọng (Q3)'),
                const SizedBox(height: 6),
                _buildLegendItem(colors[3], 'Không quan trọng, Không khẩn (Q4)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  String _getTaskKey(Task task) {
    if (task.isDone) return TaskService.notUrgentImportantKey;
    return TaskService.urgentImportantKey;
  }
}