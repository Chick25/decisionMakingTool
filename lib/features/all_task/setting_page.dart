import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;

  // Các biến trạng thái cho phần Settings
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _defaultReminder = "15 phút trước";

  // ==================== 4 MÀU CỦA MA TRẬN ====================
  Color _colorUrgentImportant = Colors.red;
  Color _colorNotUrgentImportant = const Color(0xFF0CCEF0);
  Color _colorUrgentNotImportant = const Color(0xFF0FFF1F);
  Color _colorNotUrgentNotImportant = const Color(0xFFFFEE00);

  // Danh sách màu gợi ý
  final List<Color> _colorPalette = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void dispose() {
  _emailController.dispose();
  _usernameController.dispose();
  _passwordController.dispose();
  super.dispose();
}
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.isLoggedIn ? 'Cài đặt' : 'Đăng nhập / Đăng ký'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: auth.isLoggedIn 
          ? _buildLoggedInSettings(auth) 
          : _buildLoginRegisterForm(auth),
    );
  }

  // ==================== GIAO DIỆN KHI ĐÃ ĐĂNG NHẬP ====================
  Widget _buildLoggedInSettings(AuthProvider auth) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Tài khoản'),
        ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              auth.username.isNotEmpty ? auth.username[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(auth.username),
          subtitle: Text(auth.email),
          trailing: const Icon(Icons.edit),
        ),
        const Divider(),

        _buildSectionHeader('Giao diện'),
        SwitchListTile(
          title: const Text('Chế độ tối (Dark Mode)'),
          subtitle: const Text('Bật/tắt giao diện tối'),
          value: Provider.of<ThemeProvider>(context).isDarkMode,
          onChanged: (value) {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
        ListTile(
          title: const Text('Tùy chỉnh màu Ma trận Eisenhower'),
          subtitle: const Text('Thay đổi màu 4 vùng'),
          trailing: const Icon(Icons.grid_4x4),
          onTap: () => _showMatrixColorDialog(),
        ),
        const Divider(),

        _buildSectionHeader('Thông báo'),
        SwitchListTile(
          title: const Text('Bật thông báo nhắc nhở'),
          value: _notificationsEnabled,
          onChanged: (value) => setState(() => _notificationsEnabled = value),
        ),
        ListTile(
          title: const Text('Nhắc nhở mặc định'),
          subtitle: Text(_defaultReminder),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        const Divider(),

        _buildSectionHeader('Quản lý dữ liệu'),
        ListTile(
          leading: const Icon(Icons.cleaning_services, color: Colors.orange),
          title: const Text('Xóa tất cả task đã hoàn thành'),
          onTap: _confirmClearCompletedTasks,
        ),
        ListTile(
          leading: const Icon(Icons.upload_file, color: Colors.blue),
          title: const Text('Xuất dữ liệu (CSV)'),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Xóa toàn bộ dữ liệu'),
          subtitle: const Text('Reset ứng dụng về mặc định'),
          onTap: _confirmResetAllData,
        ),
        const Divider(),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          onTap: () {
            auth.logout();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã đăng xuất thành công')),
            );
          },
        ),
      ],
    );
  }

  // ==================== FORM ĐĂNG NHẬP / ĐĂNG KÝ MỚI ====================
  Widget _buildLoginRegisterForm(AuthProvider auth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isLoginMode ? Icons.login_rounded : Icons.person_add_rounded,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),

            Text(
              _isLoginMode ? 'Đăng nhập' : 'Tạo tài khoản mới',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoginMode 
                  ? 'Chào mừng bạn quay trở lại' 
                  : 'Hãy tạo tài khoản để sử dụng đầy đủ tính năng',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Username (chỉ hiện khi đăng ký)
            if (!_isLoginMode) ...[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Tên người dùng',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 30),

            // Nút hành động
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                    );
                    return;
                  }

                  if (_isLoginMode) {
                    // Đăng nhập
                    bool success = await auth.login(email, password);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đăng nhập thành công!'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email hoặc mật khẩu không đúng'), backgroundColor: Colors.red),
                      );
                    }
                  } else {
                    // Đăng ký
                    final username = _usernameController.text.trim();
                    if (username.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập tên người dùng')),
                      );
                      return;
                    }
                    await auth.register(username, email, password);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đăng ký thành công!'), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isLoginMode ? 'Đăng nhập' : 'Tạo tài khoản',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                setState(() => _isLoginMode = !_isLoginMode);
                _emailController.clear();
                _usernameController.clear();
                _passwordController.clear();
              },
              child: Text(
                _isLoginMode 
                    ? 'Chưa có tài khoản? Đăng ký ngay' 
                    : 'Đã có tài khoản? Đăng nhập',
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ==================== DIALOG CHỌN MÀU MA TRẬN ====================
    // ==================== DIALOG TÙY CHỈNH MÀU (ĐÃ SỬA LẠI) ====================
  void _showMatrixColorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tùy chỉnh màu Ma trận Eisenhower'),
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              content: SizedBox(
                width: 460,   // Tăng chiều rộng dialog
                height: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildColorPickerRow(
                        "1. Khẩn cấp & Quan trọng",
                        _colorUrgentImportant,
                        (c) => setDialogState(() => _colorUrgentImportant = c),
                      ),
                      _buildColorPickerRow(
                        "2. Quan trọng (không khẩn cấp)",
                        _colorNotUrgentImportant,
                        (c) => setDialogState(() => _colorNotUrgentImportant = c),
                      ),
                      _buildColorPickerRow(
                        "3. Khẩn cấp (không quan trọng)",
                        _colorUrgentNotImportant,
                        (c) => setDialogState(() => _colorUrgentNotImportant = c),
                      ),
                      _buildColorPickerRow(
                        "4. Không khẩn cấp & Không quan trọng",
                        _colorNotUrgentNotImportant,
                        (c) => setDialogState(() => _colorNotUrgentNotImportant = c),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Đã lưu màu mới')),
                    );
                  },
                  child: const Text('Lưu thay đổi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== HÀM ROW CHỌN MÀU (ĐÃ TỐI ƯU) ====================
  Widget _buildColorPickerRow(
    String title,
    Color currentColor,
    Function(Color) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(                    // ← Đổi từ Row sang Column để tránh tràn ngang
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề + Màu hiện tại
          Row(
            children: [
              Container(
                width: 60,
                height: 36,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Danh sách màu
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorPalette.map((color) {
              final isSelected = currentColor == color;
              return GestureDetector(
                onTap: () => onSelected(color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black87 : Colors.grey.shade300,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _confirmClearCompletedTasks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng xóa task đã hoàn thành')),
    );
  }

  void _confirmResetAllData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng reset dữ liệu')),
    );
  }
}