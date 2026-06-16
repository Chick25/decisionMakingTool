import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../widgets/taskitem.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Lọc task theo ngày
  List<Task> _getTasksForDay(DateTime day, TaskProvider provider) {
    final allTasks = [
      ...provider.urgentImportant,
      ...provider.notUrgentImportant,
      ...provider.urgentNotImportant,
      ...provider.notUrgentNotImportant
    ];
    return allTasks.where((task) {
      return task.deadline != null &&
          task.deadline!.year == day.year &&
          task.deadline!.month == day.month &&
          task.deadline!.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasksForSelectedDay = _getTasksForDay(_selectedDay ?? _focusedDay, provider);

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) => setState(() => _calendarFormat = format),
              ),
              const Divider(),
              Expanded(
                child: tasksForSelectedDay.isEmpty
                    ? const Center(child: Text("Không có công việc nào trong ngày này"))
                    : ListView.builder(
                        itemCount: tasksForSelectedDay.length,
                        itemBuilder: (context, index) {
                          return TaskItem(
                            task: tasksForSelectedDay[index],
                            onChanged: (val) {}, // Cần truyền logic update vào đây
                            onDelete: () {},     // Cần truyền logic delete vào đây
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}