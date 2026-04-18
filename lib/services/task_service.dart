// import 'package:hive_flutter/hive_flutter.dart';
// import '../models/task.dart';

// class TaskService {
//   static const String _boxName = 'tasks';

//   // 4 Key cho 4 vùng trong ma trận Eisenhower
//   static const String urgentImportantKey = 'urgent_important';
//   static const String notUrgentImportantKey = 'not_urgent_important';
//   static const String urgentNotImportantKey = 'urgent_not_important';
//   static const String notUrgentNotImportantKey = 'not_urgent_not_important';

//   // Lấy Box
//   Future<Box<List<Task>>> get _box async => 
//       await Hive.openBox<List<Task>>(_boxName);

//   // ==================== LẤY DANH SÁCH TASK ====================
//   Future<List<Task>> getTasks(String key) async {
//     final box = await _box;
//     return box.get(key, defaultValue: <Task>[]) ?? <Task>[];
//   }

//   // ==================== THÊM TASK ====================
//   Future<void> addTask(String key, Task task) async {
//     final box = await _box;
//     final currentList = await getTasks(key);
//     currentList.add(task);
//     await box.put(key, currentList);
//   }

//   // ==================== ĐÁNH DẤU HOÀN THÀNH ====================
//   Future<void> toggleDone(String key, Task task) async {
//     final box = await _box;
//     final currentList = await getTasks(key);
    
//     final index = currentList.indexWhere((t) =>
//         t.title == task.title && t.createdAt == task.createdAt);

//     if (index != -1) {
//       currentList[index].isDone = !currentList[index].isDone;
//       await box.put(key, currentList);
//     }
//   }

//   // ==================== XÓA TASK ====================
//   Future<void> deleteTask(String key, Task task) async {
//     final box = await _box;
//     final currentList = await getTasks(key);
    
//     currentList.removeWhere((t) =>
//         t.title == task.title && t.createdAt == task.createdAt);
    
//     await box.put(key, currentList);
//   }

//   // ==================== XÓA TẤT CẢ TASK TRONG MỘT VÙNG ====================
//   Future<void> clearTasks(String key) async {
//     final box = await _box;
//     await box.put(key, <Task>[]);
//   }
// }

import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskService {
  static const String _boxName = 'tasks';

  static const String urgentImportantKey = 'urgent_important';
  static const String notUrgentImportantKey = 'not_urgent_important';
  static const String urgentNotImportantKey = 'urgent_not_important';
  static const String notUrgentNotImportantKey = 'not_urgent_not_important';

  Future<Box> get _box async => await Hive.openBox(_boxName);

  // Lấy danh sách task an toàn cho Web
  Future<List<Task>> getTasks(String key) async {
    final box = await _box;
    final dynamic data = box.get(key);

    if (data == null) {
      await box.put(key, <Task>[]);
      return <Task>[];
    }

    if (data is List) {
      return data.cast<Task>();        // Cast an toàn
    }

    return <Task>[];
  }

  Future<void> addTask(String key, Task task) async {
    final box = await _box;
    final list = await getTasks(key);
    list.add(task);
    await box.put(key, list);
  }

  Future<void> toggleDone(String key, Task task) async {
    final box = await _box;
    final list = await getTasks(key);
    
    final index = list.indexWhere((t) =>
        t.title == task.title && t.createdAt == task.createdAt);

    if (index != -1) {
      list[index].isDone = !list[index].isDone;
      await box.put(key, list);
    }
  }

  Future<void> deleteTask(String key, Task task) async {
    final box = await _box;
    final list = await getTasks(key);
    
    list.removeWhere((t) =>
        t.title == task.title && t.createdAt == task.createdAt);
    
    await box.put(key, list);
  }

  Future<void> clearTasks(String key) async {
    final box = await _box;
    await box.put(key, <Task>[]);
  }
}