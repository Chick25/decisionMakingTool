import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart'; // Gợi ý: dùng thư viện uuid để tạo id độc nhất

part 'task.g.dart'; 

@HiveType(typeId: 0)
class Task extends HiveObject {
  
  @HiveField(0)
  final String id; // Đã thêm trường ID

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? deadline;

  Task({
    String? id, // Nếu không truyền id, tự tạo mới
    required this.title,
    this.isDone = false,
    DateTime? createdAt,
    this.deadline,
  }) : this.id = id ?? const Uuid().v4(),
       this.createdAt = createdAt ?? DateTime.now();
}