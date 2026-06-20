// import 'package:flutter/material.dart';
// import '../models/task.dart';

// class TaskItem extends StatelessWidget{
//   final Task task;
//   final Function(bool?) onChanged;
//   final VoidCallback onDelete;


//   const TaskItem({
//     required this.task,
//     required this.onChanged,
//     required this.onDelete
//   });

//   @override
//   Widget build(BuildContext context) {
//   final bool isOverdue = task.deadline != null && !task.isDone && task.deadline!.isBefore(DateTime.now());
//   final bool isDueSoon = task.deadline != null && !task.isDone && task.deadline!.isAfter(DateTime.now()) && task.deadline!.difference(DateTime.now()).inHours <= 24;
//   final bool isCompleted = task.isDone;

//   // Xác định màu điểm nhấn (Accent color) thay vì màu nền
//   Color getAccentColor() {
//     if (isOverdue) return Colors.red.shade400;
//     if (isDueSoon) return Colors.orange.shade400;
//     if (isCompleted) return Colors.green.shade400;
//     return Colors.grey.shade300;
//   }

//   return Card(
//     elevation: 0, // Bỏ bóng đổ đậm
//     margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//       side: BorderSide(color: Colors.grey.shade200), // Viền nhẹ
//     ),
//     child: Container(
//       // Tạo dải màu bên trái thay vì phủ nền toàn bộ
//       decoration: BoxDecoration(
//         border: Border(left: BorderSide(color: getAccentColor(), width: 6)),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         title: Text(
//           task.title,
//           style: TextStyle(
//             decoration: isCompleted ? TextDecoration.lineThrough : null,
//             color: isCompleted ? Colors.grey : Colors.black87,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         leading: Checkbox(
//           value: task.isDone,
//           onChanged: onChanged,
//           activeColor: Colors.green,
//         ),
//         trailing: IconButton(
//           onPressed: onDelete,
//           icon: Icon(Icons.delete_outline, color: Colors.grey.shade600),
//         ),
//         subtitle: task.deadline != null 
//             ? Text(
//                 "${task.deadline!.day}/${task.deadline!.month} - ${task.deadline!.hour}:${task.deadline!.minute}",
//                 style: TextStyle(color: isOverdue ? Colors.red : Colors.grey.shade600),
//               ) 
//             : null,
//       ),
//     ),
//   );
// }

// }

import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(bool?) onChanged;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = task.deadline != null && 
        !task.isDone && 
        task.deadline!.isBefore(DateTime.now());
    
    final bool isDueSoon = task.deadline != null && 
        !task.isDone && 
        task.deadline!.isAfter(DateTime.now()) && 
        task.deadline!.difference(DateTime.now()).inHours <= 24;
        
    final bool isCompleted = task.isDone;

    Color getAccentColor() {
      if (isOverdue) return const Color(0xFFEF4444);
      if (isDueSoon) return const Color(0xFFF59E0B);
      if (isCompleted) return const Color(0xFF10B981);
      return const Color(0xFF6366F1);
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: isCompleted ? const Color(0xFFF8FAFC) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          // Thay thế colors.slate[100/200] bằng blueGrey
          color: isCompleted ? Colors.blueGrey.shade100 : Colors.blueGrey.shade200.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isCompleted ? Colors.blueGrey.shade300 : getAccentColor(), 
                width: 4.5,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            dense: true,
            leading: SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: task.isDone,
                onChanged: onChanged,
                activeColor: getAccentColor(),
                side: BorderSide(color: Colors.blueGrey.shade300, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.blueGrey.shade400 : Colors.blueGrey.shade800,
                // Sửa FontWeight.w650 thành w600
                fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
                fontSize: 13.5,
                letterSpacing: -0.15,
              ),
            ),
            subtitle: task.deadline != null 
                ? Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: isOverdue ? const Color(0xFFEF4444) : Colors.blueGrey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${task.deadline!.day}/${task.deadline!.month} • ${task.deadline!.hour.toString().padLeft(2, '0')}:${task.deadline!.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: isOverdue ? const Color(0xFFEF4444) : Colors.blueGrey.shade500,
                            fontSize: 11,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ) 
                : null,
            trailing: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.delete_outline_rounded, 
                  color: Colors.blueGrey.shade400,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}