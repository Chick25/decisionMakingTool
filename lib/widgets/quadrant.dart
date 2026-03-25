import 'package:flutter/material.dart';
import 'package:todolist/widgets/taskitem.dart';
import '../models/task.dart'; 

class QuadrantWidget extends StatelessWidget{
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
    required this.onDelete
  });

  @override
  Widget build(BuildContext context){
    return Expanded(
      child: InkWell(
        onTap: onAdd,
        child: Container(
          color: color,
          child: Column(
            children: [
              Text(title),

              Expanded(
                child: ListView(
                  children: tasks.map((task){
                    return TaskItem(
                      task: task,
                      onChanged: (value) => onToggle(task),
                      onDelete: () => onDelete(task),
                    );
                  }).toList(),
                )
              )
            ],
          ),
        ),
      )
    );
  }

}