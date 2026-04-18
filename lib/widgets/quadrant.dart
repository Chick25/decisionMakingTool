// import 'package:flutter/material.dart';
// import 'package:todolist/widgets/taskitem.dart';
// import '../models/task.dart'; 

// class QuadrantWidget extends StatelessWidget{
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
//   Widget build(BuildContext context){
//     return Expanded(
//       child: InkWell(
//         onTap: onAdd,
//         child: Container(
//           // color: color,
//           margin: EdgeInsets.all(4),
//           padding: EdgeInsets.all(4),

//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(5),
//           ),
          
//           child: Column(
           
//             children: [
//               Padding(
//                 padding: EdgeInsets.all(15),
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
                  
//                   ),
//                 ),
//               ),

//               // SizedBox(height: 15),

//               Expanded(
//                 child: ListView(
//                   padding: EdgeInsets.all(4),
//                   children: tasks.map((task){
//                     return Container(
//                       margin: EdgeInsets.only(top: 2),
//                       // padding: EdgeInsets.all(4),
//                       // decoration: BoxDecoration(
//                       //   color: Colors.white38.withValues(alpha: 0.5),
//                       //   borderRadius: BorderRadius.circular(5),
//                       // ),
          
//                       child: TaskItem(
//                         task: task,
//                         onChanged: (value) => onToggle(task),
//                         onDelete: () => onDelete(task),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               )
//             ],
//           ),
//         ),
//       )
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
    required this.title,
    required this.color,
    required this.tasks,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header với nút +
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách task
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có công việc nào',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
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
}