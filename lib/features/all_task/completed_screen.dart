import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  // Hàm xác định Key để xóa/tương tác
  String _findKeyForTask(Task task, TaskProvider provider) {
    if (provider.urgentImportant.contains(task)) return TaskService.urgentImportantKey;
    if (provider.notUrgentImportant.contains(task)) return TaskService.notUrgentImportantKey;
    if (provider.urgentNotImportant.contains(task)) return TaskService.urgentNotImportantKey;
    return TaskService.notUrgentNotImportantKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Màu nền xám nhạt cực sang
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final completedTasks = [
            ...provider.urgentImportant,
            ...provider.notUrgentImportant,
            ...provider.urgentNotImportant,
            ...provider.notUrgentNotImportant
          ].where((task) => task.isDone).toList();

          return CustomScrollView(
            slivers: [
              // Header nghệ thuật
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Mission Accomplished",
                    style: GoogleFonts.philosopher(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stars, color: Colors.white, size: 40),
                          const SizedBox(height: 10),
                          Text(
                            "${completedTasks.length} tasks finished",
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Danh sách Task
              completedTasks.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text("Keep crushing your goals!"),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = completedTasks[index];
                            final key = _findKeyForTask(task, provider);
                            return _buildModernTaskCard(context, task, key, provider);
                          },
                          childCount: completedTasks.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernTaskCard(BuildContext context, Task task, String key, TaskProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          // Đường kẻ màu nhỏ bên trái để phân biệt loại Task (Eisenhower)
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getCategoryColor(key),
                width: 6,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green),
            ),
            title: Text(
              task.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                decoration: TextDecoration.lineThrough, // Gạch ngang vì đã xong
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Completed on ${task.createdAt.day}/${task.createdAt.month}",
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => provider.deleteTask(key, task),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String key) {
    switch (key) {
      case TaskService.urgentImportantKey: return Colors.redAccent;
      case TaskService.notUrgentImportantKey: return Colors.blueAccent;
      case TaskService.urgentNotImportantKey: return Colors.orangeAccent;
      default: return Colors.grey;
    }
  }
}