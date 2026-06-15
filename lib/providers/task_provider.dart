import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> urgentImportant = [];
  List<Task> notUrgentImportant = [];
  List<Task> urgentNotImportant = [];
  List<Task> notUrgentNotImportant = [];

  TaskProvider() {
    loadAllTask();
  }
  // Box<Task> get _box => Hive.box<Task>('tasksBox');
  //Load data from HIve
  Future<void> loadAllTask() async{

    final box = Hive.box<Task>('tasksBox');
    // urgentImportant = await _taskService.getTasks(TaskService.urgentImportantKey);
    // notUrgentImportant = await _taskService.getTasks(TaskService.notUrgentImportantKey);
    // urgentNotImportant = await _taskService.getTasks(TaskService.urgentNotImportantKey);
    // notUrgentNotImportant = await _taskService.getTasks(TaskService.notUrgentNotImportantKey);

    urgentImportant = (box.get(TaskService.urgentImportantKey) as List<Task>?)?.cast<Task>() ?? [];
    notUrgentImportant = (box.get(TaskService.notUrgentImportantKey) as List<Task>?)?.cast<Task>() ?? [];
    urgentNotImportant = (box.get(TaskService.urgentNotImportantKey) as List<Task>?)?.cast<Task>() ?? [];
    notUrgentNotImportant = (box.get(TaskService.notUrgentNotImportantKey) as List<Task>?)?.cast<Task>() ?? [];
    notifyListeners();
  }

  Future<void> addTask(String key, Task task) async{
    await _taskService.addTask(key, task);

    // if (key == TaskService.urgentImportantKey) urgentImportant.add(task);
    if (key == TaskService.urgentImportantKey) urgentImportant.add(task);
    else if (key == TaskService.notUrgentImportantKey) notUrgentImportant.add(task);
    else if (key == TaskService.urgentNotImportantKey) urgentNotImportant.add(task);
    else if (key == TaskService.notUrgentNotImportantKey) notUrgentNotImportant.add(task);

    notifyListeners();
    // final currentList = await _taskService.getTasks(key);
    // final exists = currentList.any((t)=>
    //   t.title == task.title && t.createdAt == task.createdAt);
    // if(!exists){
    //   await _taskService.addTask(key, task);
    //   await loadAllTask();
    // }
  }

  //Toggle Done
  Future<void> toggleDone(String key, Task task) async{
    await _taskService.toggleDone(key, task);
    await loadAllTask(); //<-reaload để đồng bộ
  }

  //Delete task
  Future<void> deleteTask(String key, Task task) async{
    await _taskService.deleteTask(key, task);
    // await loadAllTask();
    if (key == TaskService.urgentImportantKey) urgentImportant.remove(task);
    else if (key == TaskService.notUrgentImportantKey) notUrgentImportant.remove(task);
    else if (key == TaskService.urgentNotImportantKey) urgentNotImportant.remove(task);
    else if (key == TaskService.notUrgentNotImportantKey) notUrgentNotImportant.remove(task);
    notifyListeners();
  }

  //Delete all task
  Future<void> clearTasks(String key) async{
    await _taskService.clearTasks(key);
    await loadAllTask();
  }

}