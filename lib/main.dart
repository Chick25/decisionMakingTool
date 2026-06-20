import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist/providers/task_provider.dart';
import 'package:todolist/services/task_service.dart';

import 'models/task.dart';
import 'widgets/quadrant.dart';
import 'features/all_task/all_task_screen.dart';
import 'features/all_task/setting_page.dart';  
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';   
import 'package:path_provider/path_provider.dart';
import 'features/all_task/completed_screen.dart'; 
import 'features/all_task/today_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); 

  if (!Hive.isAdapterRegistered(0)) { 
    Hive.registerAdapter(TaskAdapter());
  }

  await Hive.openBox('authbox');
  await Hive.openBox<List<dynamic>>('tasks');  
  
  var authbox = await Hive.openBox('authbox');
  print("Dữ liệu trong authbox: ${authbox.toMap()}");
  
  await Hive.openBox<Task>('tasksBox');

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

  // Lấy lời chào tiếng Việt động theo thời gian thực
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    // Tính toán số tác vụ chưa hoàn thành
    final pendingCount = taskProvider.urgentImportant.where((t) => !t.isDone).length +
        taskProvider.notUrgentImportant.where((t) => !t.isDone).length +
        taskProvider.urgentNotImportant.where((t) => !t.isDone).length +
        taskProvider.notUrgentNotImportant.where((t) => !t.isDone).length;

    return MaterialApp(
      title: 'Decision Making List',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Nền xám nhạt Sleek
      ),
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              // NavigationRail nâng cấp thành Sleek Sidebar phong cách mới
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                extended: true, // Hiển thị đầy đủ nhãn bên phải
                minWidth: 80,
                backgroundColor: Colors.white,
                elevation: null,
                // Đường kẽ mảnh mờ ngăn với vùng nội dung
                groupAlignment: -0.85,
                leading: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zenith',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Decision Matrix',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                indicatorColor: const Color(0xFFEEF2FF), // Indigo nhạt cực kỳ thanh thoát
                selectedIconTheme: const IconThemeData(color: Color(0xFF4F46E5), size: 22),
                unselectedIconTheme: const IconThemeData(color: Color(0xFF94A3B8), size: 22),
                selectedLabelTextStyle: GoogleFonts.inter(
                  color: const Color(0xFF4F46E5),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                unselectedLabelTextStyle: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: Text('Ma trận'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.playlist_add_check_outlined),
                    selectedIcon: Icon(Icons.playlist_add_check_rounded),
                    label: Text('Tổng việc'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.offline_pin_outlined),
                    selectedIcon: Icon(Icons.offline_pin_rounded),
                    label: Text('Đã xong'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today_rounded),
                    label: Text('Hôm nay'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: Text('Thiết lập'),
                  ),
                ],
              ),
              
              // Đường phân cách mờ dọc
              Container(width: 1, decoration: const BoxDecoration(color: Color(0xFFE2E8F0))),

              // Main Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 36, 40, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header lớn chuẩn Sleek Interface
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting()}, Yến',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF0F172A),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                pendingCount > 0 
                                  ? 'Hôm nay bạn có $pendingCount nhiệm vụ chưa hoàn thành.'
                                  : 'Tuyệt vời! Bạn đã hoàn thành hết các nhiệm vụ.',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF64748B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          // Nút thêm công việc & Avatar của Yến
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => showAddTaskDialog(
                                  context, 
                                  'Góc khẩn cấp', 
                                  (task) async {
                                    await taskProvider.addTask(TaskService.urgentImportantKey, task);
                                  },
                                ),
                                icon: const Icon(Icons.plus_one_outlined, size: 16),
                                label: Text(
                                  'Thêm việc',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'YN',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF4F46E5),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 28),

                      // Toàn bộ màn hình hiển thị nội dung động thay thế
                      Expanded(
                        child: _buildBody(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatrixArea() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Hàng Trên
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: QuadrantWidget(
                        title: 'Emergency & Important',
                        color: const Color(0xFFEF4444), // Crimson Red
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
                        color: const Color(0xFF3B82F6), // Sky Blue
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

              // Hàng Dưới
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: QuadrantWidget(
                        title: 'Emergency but not Important',
                        color: const Color(0xFF10B981), // Soft Green
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
                        color: const Color(0xFFF59E0B), // Solar Amber
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
        );
      },
    );
  }

 Widget _buildBody() {
    final taskProvider = Provider.of<TaskProvider>(context);
    switch (_selectedIndex) {
      case 0:
        return _buildMatrixArea();
      case 1:
        return AllTaskScreen(
          urgentImportant: taskProvider.urgentImportant,
          notUrgentImportant: taskProvider.notUrgentImportant,
          urgentNotImportant: taskProvider.urgentNotImportant,
          notUrgentNotImportant: taskProvider.notUrgentNotImportant,
        );
      case 2:
        return const CompletedScreen();  
      case 3:
        return const TodayScreen();
      case 4:
        return const SettingsScreen();   
      default:
        return Center(
          child: Text('Tính năng đang phát triển', style: GoogleFonts.inter(fontSize: 16)),
        );
    }
  }
}

void showAddTaskDialog(BuildContext context, String type, Function(Task) onSave) {
  TextEditingController controller = TextEditingController();
  bool isDone = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Thêm công việc mới',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            content: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phân nhóm: $type',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên công việc...',
                      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: isDone,
                        activeColor: const Color(0xFF4F46E5),
                        onChanged: (value) {
                          setState(() {
                            isDone = value!;
                          });
                        },
                      ),
                      Text('Đã hoàn thành', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 16),
                          label: Text(
                            selectedDate == null 
                              ? "Chọn ngày" 
                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            style: GoogleFonts.inter(fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                          icon: const Icon(Icons.access_time_filled_rounded, size: 16),
                          label: Text(
                            selectedTime == null 
                              ? "Chọn giờ" 
                              : "${selectedTime!.hour}:${selectedTime!.minute}",
                            style: GoogleFonts.inter(fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                
                child: Text('Hủy', style: GoogleFonts.inter(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  DateTime? deadline;
                  if (selectedDate != null && selectedTime != null) {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Lưu lại', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    },
  );
}

List<Task> urgentImportant = [];
List<Task> notUrgentImportant = [];
List<Task> urgentNotImportant = [];
List<Task> notUrgentNotImportant = [];