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

  // Lời chào tiếng Việt động theo múi giờ thực tế
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  // Tiện ích tự động ánh xạ góc phần tư thông minh giữa Tiếng Anh/Việt và ID q1-q4
  static String resolveQuadrantKey(String input) {
    final low = input.toLowerCase();
    if (low == 'q1' || (low.contains('emergency') && low.contains('important') && !low.contains('not'))) {
      return 'q1';
    }
    if (low == 'q2' || (low.contains('not') && low.contains('emergency') && low.contains('important') && !low.contains('not important'))) {
      if (low.contains('not important') || low.contains('not urgent & not important') || low.contains('not emergency & not important')) {
        return 'q4';
      }
      return 'q2';
    }
    if (low == 'q3' || (low.contains('emergency') && low.contains('not important')) || (low.contains('urgent') && low.contains('not important'))) {
      return 'q3';
    }
    if (low == 'q4') {
      return 'q4';
    }
    if (low.contains('khẩn cấp') && low.contains('quan trọng')) {
      return 'q1';
    }
    if (low.contains('lâu dài') || low.contains('hoạch định')) {
      return 'q2';
    }
    if (low.contains('ủy quyền') || low.contains('gây nhiễu')) {
      return 'q3';
    }
    if (low.contains('tiết chế') || low.contains('loại bỏ')) {
      return 'q4';
    }
    return 'q1';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Tính toán nhanh số tác vụ chưa hoàn thành của cả 4 quadrants
    final pendingCount = taskProvider.urgentImportant.where((t) => !t.isDone).length +
        taskProvider.notUrgentImportant.where((t) => !t.isDone).length +
        taskProvider.urgentNotImportant.where((t) => !t.isDone).length +
        taskProvider.notUrgentNotImportant.where((t) => !t.isDone).length;

    // Tính toán tiến trình tổng để đưa lên thanh Progress của React
    final totalTasks = taskProvider.urgentImportant.length +
        taskProvider.notUrgentImportant.length +
        taskProvider.urgentNotImportant.length +
        taskProvider.notUrgentNotImportant.length;
    
    final completedTasks = taskProvider.urgentImportant.where((t) => t.isDone).length +
        taskProvider.notUrgentImportant.where((t) => t.isDone).length +
        taskProvider.urgentNotImportant.where((t) => t.isDone).length +
        taskProvider.notUrgentNotImportant.where((t) => t.isDone).length;
        
    final double completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    // Thu thập kích thước màn hình để thực hiện Responsive Layout
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 850;

    return MaterialApp(
      title: 'Decision Making List',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        
        // Thiết kế Drawer vuốt chạm nhạy bén dành cho màn hình di động nhỏ gọn
        drawer: !isLargeScreen
            ? Drawer(
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: _buildSleekSidebar(context, isDark, themeProvider, completionRate, isDrawer: true),
              )
            : null,
            
        body: SafeArea(
          child: Row(
            children: [
              // MÀN HÌNH Desktop/Tablet: Hiện Sidebar cố định cực kỳ chuyên nghiệp
              if (isLargeScreen)
                _buildSleekSidebar(context, isDark, themeProvider, completionRate, isDrawer: false),
              
              if (isLargeScreen)
                Container(
                  width: 1,
                  color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFE2E8F0),
                ),
              
              // KHU VỰC TÁC VỤ TRUNG TÂM
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 36.0 : 20.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header điều khiển trên cùng (Tích hợp Drawer button nếu là Mobile)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!isLargeScreen)
                            Builder(
                              builder: (context) => IconButton(
                                icon: Icon(
                                  Icons.menu_rounded,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  size: 26,
                                ),
                                onPressed: () => Scaffold.of(context).openDrawer(),
                              ),
                            ),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, child) {
                                    return Text(
                                      '${_getGreeting()}, ${authProvider.username.isNotEmpty ? authProvider.username : "Yến"} 👋',
                                      style: GoogleFonts.inter(
                                        fontSize: isLargeScreen ? 25 : 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.8,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pendingCount > 0 
                                    ? 'Hôm nay bạn còn $pendingCount mục việc cần chinh phục.'
                                    : 'Thật tuyệt vời! Không còn việc tồn đọng nào.',
                                  style: GoogleFonts.inter(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Nút thêm công việc nhanh có bóng đổ Gradient sang trọng
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => showAddTaskDialog(
                                context, 
                                'q1', 
                                (task) async {
                                  await taskProvider.addTask(TaskService.urgentImportantKey, task);
                                },
                              ),
                              icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                              label: Text(
                                isLargeScreen ? 'Thêm việc mới' : 'Thêm',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLargeScreen ? 16 : 12,
                                  vertical: isLargeScreen ? 12 : 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // Vùng render màn hình linh động chuyển đổi mượt mà
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _buildBody(),
                        ),
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

  // SIDEBAR ĐƯỢC CHUẨN HÓA VÀ NÂNG CẤP CHI TIẾT
  Widget _buildSleekSidebar(
    BuildContext context, 
    bool isDark, 
    ThemeProvider themeProvider, 
    double completionRate,
    {required bool isDrawer}
  ) {
    final List<Map<String, dynamic>> menuItems = [
      { 'label': 'Ma trận', 'desc': 'Ma trận 2x2', 'icon': Icons.grid_view_rounded },
      { 'label': 'Tổng việc', 'desc': 'Toàn bộ tác vụ', 'icon': Icons.playlist_add_check_rounded },
      { 'label': 'Đã xong', 'desc': 'Việc hoàn thành', 'icon': Icons.offline_pin_rounded },
      { 'label': 'Hôm nay', 'desc': 'Kế hoạch ngày', 'icon': Icons.calendar_today_rounded },
      { 'label': 'Thiết lập', 'desc': 'Cài đặt hệ thống', 'icon': Icons.settings_rounded },
    ];

    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Nhận diện ứng dụng EisenHower thời trang
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eisenhower Matrix',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    'DECISION MAKING TOOL',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Menu Navigation List bo góc siêu mượt
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      if (isDrawer) {
                        Navigator.pop(context); // Tự động đóng drawer trên Mobile
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFF6366F1).withOpacity(0.06))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? const Color(0xFF4F46E5)
                                : (isDark ? const Color(0xFF64748B) : const Color(0xFF475569)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['label'].toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF4F46E5)
                                        : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B)),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  item['desc'].toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Card hiển thị tiến tình thông minh phong cách Modern Dashboard
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TIẾN ĐỘ NGÀY',
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${completionRate.round()}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completionRate / 100,
                    minHeight: 5,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dứt điểm nhóm Q1 trước để giải tỏa tâm lý Yến nhé!',
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Nút Chuyển đổi Giao diện Tối/Sáng thông minh
          InkWell(
            onTap: () {
              themeProvider.toggleTheme();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        size: 15,
                        color: isDark ? const Color(0xFF818CF8) : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDark ? 'Giao diện Tối' : 'Giao diện Sáng',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Sleek',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // KHU VỰC CHÍNH BÀN LÀM VIỆC 2X2 EISENHOWER
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
              // Hàng phía trên: Q1 (Đỏ Rose) & Q2 (Xanh Dương Sky)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: QuadrantWidget(
                        title: 'Emergency & Important',
                        color: const Color(0xFFF43F5E), // Rose 500 (Q1)
                        tasks: taskProvider.urgentImportant,
                        onAdd: () => showAddTaskDialog(
                          context, 
                          'q1', 
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
                        color: const Color(0xFF0EA5E9), // Sky 500 (Q2)
                        tasks: taskProvider.notUrgentImportant,
                        onAdd: () => showAddTaskDialog(
                          context, 
                          'q2', 
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

              // Hàng phía dưới: Q3 (Vàng Hổ Phách Amber) & Q4 (Xanh Lá Ngọc Emerald)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: QuadrantWidget(
                        title: 'Emergency but not Important',
                        color: const Color(0xFFF59E0B), // Amber 500 (Q3)
                        tasks: taskProvider.urgentNotImportant,
                        onAdd: () => showAddTaskDialog(
                          context, 
                          'q3', 
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
                        color: const Color(0xFF10B981), // Emerald 500 (Q4)
                        tasks: taskProvider.notUrgentNotImportant,
                        onAdd: () => showAddTaskDialog(
                          context, 
                          'q4', 
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
          child: Text('Tính năng đang phát triển', style: GoogleFonts.inter(fontSize: 14)),
        );
    }
  }
}

// ==================== DIALOG THÊM MỚI TÁC VỤ HOÀN MỸ (Eisenhower 2x2 Grid Dialog) ====================
void showAddTaskDialog(
  BuildContext context, 
  String initialQuadrant, 
  Function(Task) onSave, 
) {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  
  bool isCompleted = false;
  String selectedQuadrant = _MainAppState.resolveQuadrantKey(initialQuadrant);
  String selectedPriority = "medium"; // 'low', 'medium', 'high'

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Preset thiết kế đồng điệu hoàn mỹ cho từng góc phần tư
  final Map<String, Map<String, dynamic>> quadrantConfigs = {
    'q1': {
      'title': 'Q1: Khẩn & Quan trọng',
      'label': 'KHẨN CẤP',
      'accent': const Color(0xFFF43F5E), // Rose Red Accent
      'bg': const Color(0xFFFFF1F2),
    },
    'q2': {
      'title': 'Q2: Hoạch định dài hạn',
      'label': 'DÀI HẠN',
      'accent': const Color(0xFF0EA5E9), // Sky Blue Accent
      'bg': const Color(0xFFF0F9FF),
    },
    'q3': {
      'title': 'Q3: Xử lý lẹ / Ủy quyền',
      'label': 'ỦY QUYỀN',
      'accent': const Color(0xFFF59E0B), // Solar Amber Accent
      'bg': const Color(0xFFFEF3C7),
    },
    'q4': {
      'title': 'Q4: Tiết chế / Loại bỏ',
      'label': 'ÍT GIÁ TRỊ',
      'accent': const Color(0xFF10B981), // Emerald Accent
      'bg': const Color(0xFFECFDF5),
    },
  };

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;

      return StatefulBuilder(
        builder: (context, setModalState) {
          final activeConfig = quadrantConfigs[selectedQuadrant] ?? quadrantConfigs['q1']!;
          final activeColor = activeConfig['accent'] as Color;

          return Dialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () => FocusScope.of(context).unfocus(), // Chạm ngoài đóng Keyboard tự động
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Panel Dialog
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cấu hình công việc mới',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800, 
                                    fontSize: 16.5, 
                                    letterSpacing: -0.4,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sử dụng học thuyết ma trận Eisenhower để làm việc thông minh hơn.',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5, 
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded, size: 14, color: isDark ? Colors.white70 : Colors.black45),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                      const SizedBox(height: 16),

                      // Ô nhập Title
                      Text(
                        'TIÊU ĐỀ CÔNG VIỆC *',
                        style: GoogleFonts.inter(
                          fontSize: 9.5, 
                          fontWeight: FontWeight.w800, 
                          color: activeColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: Đọc tài liệu Eisenhower Matrix...',
                          hintStyle: GoogleFonts.inter(color: isDark ? const Color(0xFF475569) : Colors.grey.shade400, fontSize: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: activeColor, width: 2), 
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Ô nhập Description
                      Text(
                        'MÔ TẢ CHI TIẾT',
                        style: GoogleFonts.inter(
                          fontSize: 9.5, 
                          fontWeight: FontWeight.w800, 
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF334155)),
                        decoration: InputDecoration(
                          hintText: 'Thêm mục tiêu nhỏ hoặc kế hoạch hành động...',
                          hintStyle: GoogleFonts.inter(color: isDark ? const Color(0xFF475569) : Colors.grey.shade400, fontSize: 11.5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: activeColor, width: 2), 
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2x2 Quadrant selector (bản sao UI React tuyệt hảo)
                      Text(
                        'PHÂN LOẠI QUYẾT ĐỊNH (QUADRANT)',
                        style: GoogleFonts.inter(
                          fontSize: 9.5, 
                          fontWeight: FontWeight.w800, 
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.3,
                        children: quadrantConfigs.entries.map((entry) {
                          final isSelected = selectedQuadrant == entry.key;
                          final qColor = entry.value['accent'] as Color;
                          final qBg = isDark 
                              ? (isSelected ? qColor.withOpacity(0.12) : const Color(0xFF0F172A))
                              : (isSelected ? entry.value['bg'] as Color : const Color(0xFFF8FAFC));

                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedQuadrant = entry.key;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: qBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? qColor : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  width: isSelected ? 2.0 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected ? qColor : Colors.grey.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          entry.key.toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 8, 
                                            fontWeight: FontWeight.w800, 
                                            color: isSelected ? Colors.white : (isDark ? Colors.white38 : Colors.black45),
                                          ),
                                        ),
                                      ),
                                      if (isSelected) 
                                        Icon(Icons.check_circle_rounded, size: 12, color: qColor),
                                    ],
                                  ),
                                  Text(
                                    entry.value['title'].toString().split(': ')[1],
                                    style: GoogleFonts.inter(
                                      fontSize: 10, 
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected 
                                          ? (isDark ? qColor : qColor.withOpacity(0.95)) 
                                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Cấp độ Ưu tiên Pill-Control
                      Text(
                        'ĐỘ ƯU TIÊN HOẠT ĐỘNG',
                        style: GoogleFonts.inter(
                          fontSize: 9.5, 
                          fontWeight: FontWeight.bold, 
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildPriorityButton('low', 'Nhẹ nhàng', selectedPriority, const Color(0xFF64748B), isDark, (p) {
                              setModalState(() => selectedPriority = p);
                            }),
                            _buildPriorityButton('medium', 'Vừa', selectedPriority, const Color(0xFFF59E0B), isDark, (p) {
                              setModalState(() => selectedPriority = p);
                            }),
                            _buildPriorityButton('high', 'Cao 🔥', selectedPriority, const Color(0xFFF43F5E), isDark, (p) {
                              setModalState(() => selectedPriority = p);
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Thiết lập Hạn Chặng & Trạng Thái Hoàn Thành
                      Text(
                        'THỜI HẠN HOÀN THÀNH',
                        style: GoogleFonts.inter(
                          fontSize: 9.5, 
                          fontWeight: FontWeight.bold, 
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePickerChip(
                              context: context,
                              icon: Icons.calendar_today_rounded,
                              label: selectedDate == null 
                                  ? "Chọn ngày" 
                                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: isDark ? ThemeData.dark() : ThemeData.light(),
                                      child: child!,
                                    );
                                  }
                                );
                                if (date != null) {
                                  setModalState(() => selectedDate = date);
                                }
                              },
                              isDark: isDark,
                              activeColor: activeColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDatePickerChip(
                              context: context,
                              icon: Icons.access_time_rounded,
                              label: selectedTime == null 
                                  ? "Chọn giờ" 
                                  : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setModalState(() => selectedTime = time);
                                }
                              },
                              isDark: isDark,
                              activeColor: activeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Slider Trạng thái đã làm xong hay chưa
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Checkbox(
                              value: isCompleted,
                              activeColor: activeColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (value) {
                                setModalState(() {
                                  isCompleted = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ưu tiên đánh dấu việc này đã hoàn thiện',
                            style: GoogleFonts.inter(
                              fontSize: 11.5, 
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Toàn bộ các Button hành động cuối cùng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Hủy bỏ',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B), 
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final titleText = titleController.text.trim();
                              if (titleText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Vui lòng nhập tên công việc để tiếp tục!', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                                    backgroundColor: const Color(0xFFF43F5E),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              DateTime? deadline;
                              if (selectedDate != null) {
                                final time = selectedTime ?? const TimeOfDay(hour: 9, minute: 0);
                                deadline = DateTime(
                                  selectedDate!.year,
                                  selectedDate!.month,
                                  selectedDate!.day,
                                  time.hour,
                                  time.minute,
                                );
                              }

                              // Bảo toàn dữ liệu đầu vào logic an toàn
                              final task = Task(
                                title: titleText,
                                isDone: isCompleted,
                                deadline: deadline,
                              );

                              onSave(task);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            ),
                            child: Text(
                              'Tạo công việc',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, 
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// BỘ ĐIỀU ĐỘ ƯU TIÊN TÁC VỤ
Widget _buildPriorityButton(
  String priorityId, 
  String label, 
  String activePriorityId, 
  Color activeColor, 
  bool isDark,
  Function(String) onSelect,
) {
  final isSelected = activePriorityId == priorityId;
  return Expanded(
    child: InkWell(
      onTap: () => onSelect(priorityId),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    ),
  );
}

// CHIP CHỌN THỜI GIAN LỊCH TRÌNH
Widget _buildDatePickerChip({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  required bool isDark,
  required Color activeColor,
}) {
  return OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
    label: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11, 
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
      ),
      overflow: TextOverflow.ellipsis,
    ),
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
    ),
  );
}

// Các danh sách mẫu dự phòng bắt buộc bảo toàn theo cấu trúc cũ
List<Task> urgentImportant = [];
List<Task> notUrgentImportant = [];
List<Task> urgentNotImportant = [];
List<Task> notUrgentNotImportant = [];