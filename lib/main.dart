import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist/providers/task_provider.dart';
import 'package:todolist/services/task_service.dart';

import 'models/task.dart';
import 'widgets/quadrant.dart';
import 'features/all_task/all_task_screen.dart';
import 'features/all_task/setting_page.dart';     // ← Đảm bảo tên file đúng
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';   // Đảm bảo có dòng này
import 'providers/task_provider.dart';     // ← Thêm dòng này nếu chưa có

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter(); // Khởi tạo Hive cho Flutter
  
  Hive.registerAdapter(TaskAdapter()); // Đăng ký Adapter đã sinh ở bước 2
  
  // await Hive.openBox<Task>('tasksBox');
   // Mở hộp sẵn với tên 'tasksBox'

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadAllTask()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Decision Making List',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          toolbarHeight: 100,
          title: const Text(
            'Decision Making List',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              minExtendedWidth: 220,
              minWidth: 90,
              labelType: NavigationRailLabelType.selected,
              backgroundColor: const Color.fromARGB(255, 34, 42, 62),
              indicatorColor: const Color.fromARGB(255, 201, 201, 201).withValues(alpha: 0.5),
              selectedIconTheme: const IconThemeData(color: Color.fromARGB(255, 243, 243, 243)),
              unselectedIconTheme: const IconThemeData(color: Color.fromARGB(255, 216, 216, 216)),
              selectedLabelTextStyle: const TextStyle(
                color: Color.fromARGB(255, 201, 201, 201),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.grid_on),
                  selectedIcon: Icon(Icons.grid_on_rounded),
                  label: Text('Matrix'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.list_alt),
                  selectedIcon: Icon(Icons.list_alt_rounded),
                  label: Text('All Tasks'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.check_circle_outline),
                  selectedIcon: Icon(Icons.check_circle),
                  label: Text('Completed'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today),
                  label: Text('Today'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildMatrixArea() {

  //   final taskProvider = Provider.of<TaskProvider>(context);

  //   return Builder(
  //     builder: (context) {
  //       return Center(
  //         child: Container(
  //           height: 850,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Column(
  //             children: [
  //               Expanded(
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: QuadrantWidget(
  //                         title: 'Emergency & Important',
  //                         color: Colors.red,
  //                         tasks: urgentImportant,
  //                         onAdd: (){
  //                           showAddTaskDialog(context, 'Emergency & Important', (task) async{
  //                             await taskProvider.addTask(TaskService.urgentImportantKey, task);
  //                           });
  //                         },
  //                         onToggle: (task) async{
  //                           await taskProvider.toggleDone(TaskService.urgentImportantKey, task);
  //                         },
  //                         onDelete: (task) async{
  //                           await taskProvider.deleteTask(TaskService.urgentImportantKey, task);
  //                         },
  //                         // onAdd: () => showAddTaskDialog(context, 'Emergency & Important', (task) {
  //                         //   setState(() => urgentImportant.add(task));
  //                         // }),
  //                         // onToggle: (task) => setState(() => task.isDone = !task.isDone),
  //                         // onDelete: (task) => setState(() => urgentImportant.remove(task)),
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: QuadrantWidget(
  //                         title: 'Not Emergency but Important',
  //                         color: const Color.fromARGB(255, 12, 206, 240),
  //                         tasks: notUrgentImportant,
  //                         onAdd: (){
  //                           showAddTaskDialog(context, 'Not Emergency but Important', (task) async{
  //                             await taskProvider.addTask(TaskService.notUrgentImportantKey, task);
  //                           });
  //                         },
  //                         onToggle: (task) async{
  //                           await taskProvider.toggleDone(TaskService.notUrgentImportantKey, task);
  //                         },
  //                         onDelete: (task) async{
  //                           await taskProvider.deleteTask(TaskService.notUrgentImportantKey, task);
  //                         },
  //                         // onAdd: () => showAddTaskDialog(context, 'Not Emergency but Important', (task) {
  //                         //   setState(() => notUrgentImportant.add(task));
  //                         // }),
  //                         // onToggle: (task) => setState(() => task.isDone = !task.isDone),
  //                         // onDelete: (task) => setState(() => notUrgentImportant.remove(task)),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: QuadrantWidget(
  //                         title: 'Emergency but not Important',
  //                         color: const Color.fromARGB(255, 15, 255, 31),
  //                         tasks: urgentNotImportant,
  //                         onAdd: () {
  //                           showAddTaskDialog(context, 'Emergency but not Important', (task) async {
  //                             await taskProvider.addTask(TaskService.urgentNotImportantKey, task);
  //                           });
  //                         },
  //                         onToggle: (task) async {
  //                           await taskProvider.toggleDone(TaskService.urgentNotImportantKey, task);
  //                         },
  //                         onDelete: (task) async {
  //                           await taskProvider.deleteTask(TaskService.urgentNotImportantKey, task);
  //                         },
  //                         // onAdd: () => showAddTaskDialog(context, 'Emergency but not Important', (task) {
  //                         //   setState(() => urgentNotImportant.add(task));
  //                         // }),
  //                         // onToggle: (task) => setState(() => task.isDone = !task.isDone),
  //                         // onDelete: (task) => setState(() => urgentNotImportant.remove(task)),
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: QuadrantWidget(
  //                         title: 'Not Emergency & not Important',
  //                         color: const Color.fromARGB(255, 255, 238, 0),
  //                         tasks: notUrgentNotImportant,
  //                         onAdd: () {
  //                           showAddTaskDialog(context, 'Not Emergency & not Important', (task) async {
  //                             await taskProvider.addTask(TaskService.notUrgentNotImportantKey, task);
  //                           });
  //                         },
  //                         onToggle: (task) async {
  //                           await taskProvider.toggleDone(TaskService.notUrgentNotImportantKey, task);
  //                         },
  //                         onDelete: (task) async {
  //                           await taskProvider.deleteTask(TaskService.notUrgentNotImportantKey, task);
  //                         },
  //                         // onAdd: () => showAddTaskDialog(context, 'Not Emergency & not Important', (task) {
  //                         //   setState(() => notUrgentNotImportant.add(task));
  //                         // }),
  //                         // onToggle: (task) => setState(() => task.isDone = !task.isDone),
  //                         // onDelete: (task) => setState(() => notUrgentNotImportant.remove(task)),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

    Widget _buildMatrixArea() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Center(
          child: Container(
            // width: ,
            height: 850,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                // Hàng trên
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: QuadrantWidget(
                          title: 'Emergency & Important',
                          color: Colors.red,
                          tasks: taskProvider.urgentImportant,
                          onAdd: () => showAddTaskDialog(
                            context, 
                            'Emergency & Important', 
                            (task) async {
                              await taskProvider.addTask(TaskService.urgentImportantKey, task);
                            },
                          ),
                          onToggle: (task) async => await taskProvider.toggleDone(TaskService.urgentImportantKey, task),
                          onDelete: (task) async => await taskProvider.deleteTask(TaskService.urgentImportantKey, task),
                        ),
                      ),
                      Expanded(
                        child: QuadrantWidget(
                          title: 'Not Emergency but Important',
                          color: const Color.fromARGB(255, 12, 206, 240),
                          tasks: taskProvider.notUrgentImportant,
                          onAdd: () => showAddTaskDialog(
                            context, 
                            'Not Emergency but Important', 
                            (task) async {
                              await taskProvider.addTask(TaskService.notUrgentImportantKey, task);
                            },
                          ),
                          onToggle: (task) async => await taskProvider.toggleDone(TaskService.notUrgentImportantKey, task),
                          onDelete: (task) async => await taskProvider.deleteTask(TaskService.notUrgentImportantKey, task),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hàng dưới
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: QuadrantWidget(
                          title: 'Emergency but not Important',
                          color: const Color.fromARGB(255, 15, 255, 31),
                          tasks: taskProvider.urgentNotImportant,
                          onAdd: () => showAddTaskDialog(
                            context, 
                            'Emergency but not Important', 
                            (task) async {
                              await taskProvider.addTask(TaskService.urgentNotImportantKey, task);
                            },
                          ),
                          onToggle: (task) async => await taskProvider.toggleDone(TaskService.urgentNotImportantKey, task),
                          onDelete: (task) async => await taskProvider.deleteTask(TaskService.urgentNotImportantKey, task),
                        ),
                      ),
                      Expanded(
                        child: QuadrantWidget(
                          title: 'Not Emergency & not Important',
                          color: const Color.fromARGB(255, 255, 238, 0),
                          tasks: taskProvider.notUrgentNotImportant,
                          onAdd: () => showAddTaskDialog(
                            context, 
                            'Not Emergency & not Important', 
                            (task) async {
                              await taskProvider.addTask(TaskService.notUrgentNotImportantKey, task);
                            },
                          ),
                          onToggle: (task) async => await taskProvider.toggleDone(TaskService.notUrgentNotImportantKey, task),
                          onDelete: (task) async => await taskProvider.deleteTask(TaskService.notUrgentNotImportantKey, task),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMatrixArea();
      case 1:
        return AllTaskScreen(
          urgentImportant: urgentImportant,
          notUrgentImportant: notUrgentImportant,
          urgentNotImportant: urgentNotImportant,
          notUrgentNotImportant: notUrgentNotImportant,
        );
      case 4:
        return const SettingsScreen();   // ← Sửa ở đây
      default:
        return const Center(
          child: Text('Tính năng đang phát triển', style: TextStyle(fontSize: 18)),
        );
    }
  }
}

void showAddTaskDialog(BuildContext context, String type, Function(Task) onSave){
  TextEditingController controller = TextEditingController();
  bool isDone = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  showDialog(
    context: context,
    builder: (context){
      return StatefulBuilder(
        builder: (context, setState){
          return AlertDialog(
            title: Text('Add task ($type)'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Add work ...',
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isDone,
                      onChanged: (value){
                        setState((){
                          isDone = value!;
                        });
                      },
                    ),
                    Text('Done'),
                  ],
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () async{
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if(date !=null){
                      setState((){
                        selectedDate = date;
                      });
                    }
                  },
                  child: Text(
                    selectedDate == null ? "Select date" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                  ),
                ),

                TextButton(
                  onPressed: () async{
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if(time!=null){
                      setState((){
                        selectedTime = time;
                      });
                    }
                  },
                  child: Text(
                    selectedTime == null ? "Select time" : "${selectedTime!.hour}:${selectedTime!.minute}",
                  ),
                ),

              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (){
                  DateTime? deadline;

                  if(selectedDate != null && selectedTime !=null){
                    deadline = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );
                  }

                  final task = Task(
                    title: controller.text,
                    isDone: isDone,
                    deadline: deadline,
                   
                  );
                  onSave(task);
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        }
      );
    }
  );
}

List<Task> urgentImportant = [];
List<Task> notUrgentImportant = [];
List<Task> urgentNotImportant = [];
List<Task> notUrgentNotImportant = [];
