

// import 'package:flutter/material.dart';
// import 'package:todolist/widgets/taskitem.dart';
// import '../models/task.dart'; 

// class QuadrantWidget extends StatelessWidget {
//   final String title;
//   final Color color;
//   final List<Task> tasks;
//   final VoidCallback onAdd;
//   final Function(Task) onToggle;
//   final Function(Task) onDelete;

//   const QuadrantWidget({
//     required this.title,
//     required this.color,
//     required this.tasks,
//     required this.onAdd,
//     required this.onToggle,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           // Header với nút +
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 InkWell(
//                   onTap: onAdd,
//                   borderRadius: BorderRadius.circular(20),
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.25),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.add, color: Colors.white, size: 24),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Danh sách task
//           Expanded(
//             child: tasks.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'Chưa có công việc nào',
//                       style: TextStyle(color: Colors.white70, fontSize: 14),
//                     ),
//                   )
//                 : ListView.builder(
//                     shrinkWrap: true, // Thêm dòng này
//                     physics: const ClampingScrollPhysics(),
//                     padding: const EdgeInsets.all(8),
//                     itemCount: tasks.length,
//                     itemBuilder: (context, index) {
//                       final task = tasks[index];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 6),
//                         child: TaskItem(
//                           task: task,
//                           onChanged: (value) => onToggle(task),
//                           onDelete: () => onDelete(task),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }


// }

import 'package:flutter/material.dart';
import 'package:todolist/widgets/taskitem.dart';
import '../models/task.dart';

class QuadrantWidget extends StatelessWidget {
  final String title;
  final Color color;
  final List<Task> tasks;
  final VoidCallback onAdd;
  final Function(Task) onToggle;
  final Function(Task) onDelete;

  const QuadrantWidget({
    super.key,
    required this.title,
    required this.color,
    required this.tasks,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Sử dụng withValues cho chuẩn mới
    final Color softBackgroundColor = color.withValues(alpha: 0.08);
    final Color borderStrokeColor = color.withValues(alpha: 0.18);

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderStrokeColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle, // Đã sửa
                        ),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 15,
                            fontWeight: FontWeight.w700, // Đã sửa
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: softBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.add_rounded,
                        color: color,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: Colors.blueGrey[100], // Thay thế Colors.slate[100]
              height: 1,
              thickness: 1,
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: TaskItem(
                          task: task,
                          onChanged: (value) => onToggle(task),
                          onDelete: () => onDelete(task),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wb_sunny_rounded,
              color: color.withValues(alpha: 0.18),
              size: 32,
            ),
            const SizedBox(height: 12),
            const Text(
              'Chưa có công việc nào',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nhấp nút "+" ở trên để lên lịch trình.',
              style: TextStyle(
                color: Colors.blueGrey[300], // Thay thế Colors.slate[300]
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}