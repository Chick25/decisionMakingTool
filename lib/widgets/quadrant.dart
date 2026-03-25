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
          // color: color,
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(4),

          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          
          child: Column(
           
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              // SizedBox(height: 15),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(8),
                  children: tasks.map((task){
                    return TaskItem(
                      task: task,
                      onChanged: (value) => onToggle(task),
                      onDelete: () => onDelete(task),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

}