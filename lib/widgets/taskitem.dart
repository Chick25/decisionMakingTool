import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget{
  final Task task;
  final Function(bool?) onChanged;
  final VoidCallback onDelete;


  const TaskItem({
    required this.task,
    required this.onChanged,
    required this.onDelete
  });

  @override
  Widget build(BuildContext context){

    final bool isOverdue = task.deadline != null && !task.isDone && task.deadline!.isBefore(DateTime.now());

    final bool isDueSoon = task.deadline != null && !task.isDone && task.deadline!.isAfter(DateTime.now()) && task.deadline!.difference(DateTime.now()).inHours <= 24;

    final bool isCompleted = task.isDone;


    Color getBackgroundColor(bool isOverdue, bool isDueSoon, bool isCompleted) {
      if (isOverdue) return const Color.fromARGB(255, 184, 12, 0)!;
      if (isDueSoon) return Colors.orange[500]!;
      if (isCompleted) return const Color.fromARGB(255, 9, 170, 1)!;
      return Colors.white;
    }

    return Card(
      // margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      // color: isOverdue?  const Color.fromARGB(255, 255, 14, 14) : Colors.white.withValues(alpha: 0.7),
      color: getBackgroundColor(isOverdue, isDueSoon, isCompleted),


      child: ListTile(

        // color: isOverdue? const Color.fromARGB(255, 255, 0, 0) : Colors.white,

        leading: Checkbox(
          value: task.isDone,
          onChanged: onChanged,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone 
                  ? TextDecoration.lineThrough 
                  : TextDecoration.none,
            // color: isOverdue ? const Color.fromARGB(255, 255, 255, 255) : null,
          ),
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: Icon(Icons.delete),
        ),
        subtitle: task.deadline != null ? Text("${task.deadline}", style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),) : null,
        // tileColor: task.deadline != null && !task.isDone && task.deadline!.isBefore(DateTime.now()) ? const Color.fromARGB(255, 255, 0, 25) : null,
      )
    );
  }
}