import 'package:hive_flutter/hive_flutter.dart';

part 'task.g.dart'; // File này sẽ được tự động sinh ra

@HiveType(typeId: 0)   // typeId phải là số duy nhất, không trùng với các model khác
class Task extends HiveObject {
  
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime? deadline;

 

  Task({
    required this.title,
   
    this.isDone = false,
    DateTime? createdAt,
    this.deadline,
  }) : createdAt = createdAt ?? DateTime.now();

  // Helper method tiện lợi
  factory Task.create({
    required String title,
  
    DateTime? deadline,
  }) {
    return Task(
      title: title,
      deadline: deadline,
   
    );
  }
}