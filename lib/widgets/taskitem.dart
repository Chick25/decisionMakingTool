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
    return ListTile(
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
        ),
      ),
      trailing: IconButton(
        onPressed: onDelete,
        icon: Icon(Icons.delete),
      ),
    );
  }
}