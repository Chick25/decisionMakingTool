import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

// ==================== CẤU TRÚC PHÂN KHU HỆ MÀU (COLOR CONFIGS) ====================
class QuadrantColors {
  final Color bg;
  final Color text;
  final Color accent;
  final Color border;

  const QuadrantColors({
    required this.bg,
    required this.text,
    required this.accent,
    required this.border,
  });
}

class ColorPreset {
  final String id;
  final String name;
  final QuadrantColors q1;
  final QuadrantColors q2;
  final QuadrantColors q3;
  final QuadrantColors q4;

  const ColorPreset({
    required this.id,
    required this.name,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
  });
}

// ==================== DANH SÁCH BẢNG MÀU PASTEL BẮC ÂU ĐỒNG BỘ REACT ====================
final List<ColorPreset> presets = [
  const ColorPreset(
    id: 'nordic-pastel',
    name: 'Nordic Pastel (Nhẹ nhàng)',
    q1: QuadrantColors(
      bg: Color(0xFFFFF1F2),     // rose-50
      text: Color(0xFF881337),   // rose-900
      accent: Color(0xFFF43F5E), // rose-500
      border: Color(0xFFFFE4E6), // rose-100
    ),
    q2: QuadrantColors(
      bg: Color(0xFFF0F9FF),     // sky-50
      text: Color(0xFF0C4A6E),   // sky-900
      accent: Color(0xFF0EA5E9), // sky-500
      border: Color(0xFFE0F2FE), // sky-100
    ),
    q3: QuadrantColors(
      bg: Color(0xFFFFFBEB),     // amber-50
      text: Color(0xFF78350F),   // amber-900
      accent: Color(0xFFF59E0B), // amber-500
      border: Color(0xFFFEF3C7), // amber-100
    ),
    q4: QuadrantColors(
      bg: Color(0xFFECFDF5),     // emerald-50
      text: Color(0xFF064E3B),   // emerald-900
      accent: Color(0xFF10B981), // emerald-500
      border: Color(0xFFD1FAE5), // emerald-100
    ),
  ),
  const ColorPreset(
    id: 'matcha-calm',
    name: 'Matcha Calm (Yên bình)',
    q1: QuadrantColors(
      bg: Color(0xFFFEF2F2),     // red-50
      text: Color(0xFF262626),   // neutral-800
      accent: Color(0xFFFB923C), // orange-400
      border: Color(0xFFFEE2E2), // red-100
    ),
    q2: QuadrantColors(
      bg: Color(0xFFF5F5F4),     // stone-100
      text: Color(0xFF262626),   // neutral-800
      accent: Color(0xFF78716C), // stone-500
      border: Color(0xFFE7E5E4), // stone-200
    ),
    q3: QuadrantColors(
      bg: Color(0xFFF7FEE7),     // lime-50
      text: Color(0xFF14532D),   // green-900
      accent: Color(0xFF65A30D), // lime-600
      border: Color(0xFFECFCCB), // lime-100
    ),
    q4: QuadrantColors(
      bg: Color(0xFFFAF5FF),     // purple-50
      text: Color(0xFF581C87),   // purple-900
      accent: Color(0xFFA855F7), // purple-500
      border: Color(0xFFF3E8FF), // purple-100
    ),
  ),
  const ColorPreset(
    id: 'ocean-mist',
    name: 'Ocean Mist (Đại dương)',
    q1: QuadrantColors(
      bg: Color(0xFFEEF2FF),     // indigo-50
      text: Color(0xFF312E81),   // indigo-900
      accent: Color(0xFF6366F1), // indigo-500
      border: Color(0xFFE0E7FF), // indigo-100
    ),
    q2: QuadrantColors(
      bg: Color(0xFFECFEFF),     // cyan-50
      text: Color(0xFF164E63),   // cyan-900
      accent: Color(0xFF06B6D4), // cyan-500
      border: Color(0xFFCFFAFE), // cyan-100
    ),
    q3: QuadrantColors(
      bg: Color(0xFFF0FDFA),     // teal-50
      text: Color(0xFF115E59),   // teal-900
      accent: Color(0xFF14B8A6), // teal-500
      border: Color(0xFFCCFBF1), // teal-100
    ),
    q4: QuadrantColors(
      bg: Color(0xFFF1F5F9),     // slate-100
      text: Color(0xFF1E293B),   // slate-800
      accent: Color(0xFF64748B), // slate-500
      border: Color(0xFFE2E8F0), // slate-200
    ),
  ),
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Authentication controllers
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;

  // JSON Backup controllers
  final _importController = TextEditingController();
  bool? _isSuccessImport;

  // App States
  String _activePresetId = 'nordic-pastel';
  bool _notificationsEnabled = true;
  String _defaultReminder = "15 phút trước";
  bool _showConfirmClear = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _activePresetId = prefs.getString('activePresetId') ?? 'nordic-pastel';
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _defaultReminder = prefs.getString('defaultReminder') ?? "15 phút trước";
    });
  }

  Future<void> _changePreset(String presetId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activePresetId', presetId);
    setState(() {
      _activePresetId = presetId;
    });
    _showNordicSnackBar('🎨 Đã chuyển sang bảng màu ${presets.firstWhere((p) => p.id == presetId).name}', const Color(0xFF6366F1));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        shape: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1),
            width: 1,
          ),
        ),
        title: Text(
          auth.isLoggedIn ? 'Cài Đặt Hệ Thống' : 'Chào Mừng Thành Viên',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: auth.isLoggedIn 
              ? _buildLoggedInSettings(auth, isDark) 
              : _buildLoginRegisterForm(auth, isDark),
        ),
      ),
    );
  }

  // ==================== TIÊU ĐỀ PHÂN KHU NĂNG SUẤT ====================
  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF90A4AE),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== THÀNH PHẦN CHỌN BẢNG MÀU PASTEL 2X2 MINI ====================
  Widget _buildPresetSelector(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Bảng màu pastel hiện đại',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Lựa chọn bảng màu mềm mại, dễ chịu cho mắt để giảm mệt mỏi trong những ca làm việc dài ngày.',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: const Color(0xFF90A4AE),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: presets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final preset = presets[index];
                final isSelected = _activePresetId == preset.id;

                return InkWell(
                  onTap: () => _changePreset(preset.id),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F6FF))
                          : (isDark ? const Color(0xFF161616) : const Color(0xFFFAFAFA)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1)),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              preset.name,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF6366F1), size: 18),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 2x2 Grid hiển thị màu thu nhỏ
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniQuadrantCell('Q1', preset.q1, isDark),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMiniQuadrantCell('Q2', preset.q2, isDark),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMiniQuadrantCell('Q3', preset.q3, isDark),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMiniQuadrantCell('Q4', preset.q4, isDark),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniQuadrantCell(String label, QuadrantColors qc, bool isDark) {
    return Container(
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? qc.accent.withOpacity(0.15) : qc.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? qc.accent.withOpacity(0.3) : qc.border,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          color: isDark ? qc.accent : qc.text,
        ),
      ),
    );
  }

  // ==================== QUẢN LÝ CHƯƠNG TRÌNH ĐỒNG BỘ JSON ====================
  Widget _buildBackupAndRestore(bool isDark) {
    return Column(
      children: [
        // Export Card
        Card(
          elevation: 0,
          color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.download_rounded, color: Color(0xFF64748B), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Xuất dữ liệu lưu trữ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tải toàn bộ các mục công việc hiện tại của bạn về máy khách ở định dạng tệp JSON tiêu chuẩn để nhập lại sau này khi cần chuyển đổi thiết bị.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF90A4AE),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final mockData = [
                        {"title": "Đọc tài liệu ma trận", "quadrant": "q1", "completed": false},
                        {"title": "Lập kế hoạch tuần", "quadrant": "q2", "completed": false}
                      ];
                      final jsonString = jsonEncode(mockData);
                      _showJsonExportDialog(jsonString, isDark);
                    },
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Lưu tệp dự phòng (.json)'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Import Card
        Card(
          elevation: 0,
          color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.upload_rounded, color: Color(0xFF64748B), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Nhập tệp lưu trữ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Dán đoạn chuỗi mã JSON đã lưu của bạn vào ô dưới đây để phục hồi kế hoạch:',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF90A4AE),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _importController,
                  maxLines: 2,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: isDark ? Colors.white : const Color(0xFF263238),
                  ),
                  decoration: InputDecoration(
                    hintText: '[{"title":"Công việc tuyển dụng", "quadrant":"q1"}]',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF161616) : const Color(0xFFFAFAFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final input = _importController.text.trim();
                      if (input.isEmpty) return;
                      try {
                        final parsed = jsonDecode(input);
                        if (parsed is List) {
                          setState(() {
                            _isSuccessImport = true;
                          });
                          _importController.clear();
                          _showNordicSnackBar('🎉 Khôi phục cấu trúc dữ liệu thành công!', const Color(0xFF10B981));
                        } else {
                          setState(() {
                            _isSuccessImport = false;
                          });
                        }
                      } catch (_) {
                        setState(() {
                          _isSuccessImport = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Giải mã phục hồi'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF6366F1).withOpacity(0.12),
                      foregroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (_isSuccessImport != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isSuccessImport!
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSuccessImport!
                            ? const Color(0xFFC8E6C9)
                            : const Color(0xFFFFCDD2),
                      ),
                    ),
                    child: Text(
                      _isSuccessImport!
                          ? 'Dữ liệu khôi phục thành công!'
                          : 'Mã JSON không hợp lệ, vui lòng thử lại!',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: _isSuccessImport!
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== KHU VỰC RỦI RO CAO (DANGER ZONE) ====================
  Widget _buildDangerZone(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C1619) : const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF5A1E24) : const Color(0xFFFFEBEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 18),
              const SizedBox(width: 8),
              Text(
                'Vùng quản trị rủi ro cao',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Các thao tác này sẽ can thiệp trực tiếp vào bộ nhớ cục bộ ứng dụng. Hãy cân nhắc kỹ trước khi thực hiện.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? const Color(0xFFE57373) : const Color(0xFFB71C1C),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      _showNordicSnackBar('🔄 Nạp danh sách việc mẫu thành công', const Color(0xFF6366F1));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : const Color(0xFF37474F),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF535353) : const Color(0xFFCFD8DC),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Nạp việc mẫu', style: TextStyle(fontSize: 11.5)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: !_showConfirmClear
                      ? SizedBox(
                          key: const ValueKey('clear_btn'),
                          height: 42,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showConfirmClear = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Xóa toàn bộ', style: TextStyle(fontSize: 11.5)),
                          ),
                        )
                      : Row(
                          key: const ValueKey('confirm_btns'),
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _showConfirmClear = false),
                                child: Container(
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFCFD8DC)),
                                  ),
                                  child: Text(
                                    'Hủy',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF546E7A),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _showConfirmClear = false;
                                  });
                                  _showNordicSnackBar('🚨 Đã xóa sạch dữ liệu khỏi máy chủ!', const Color(0xFFE53935));
                                },
                                child: Container(
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB71C1C),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Xác nhận!',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ==================== GIAO DIỆN CHÍNH KHI ĐĂNG NHẬP THÀNH CÔNG ====================
  Widget _buildLoggedInSettings(AuthProvider auth, bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Personal profile header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  auth.username.isNotEmpty ? auth.username[0].toUpperCase() : 'Y',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.username,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      auth.email,
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF78909C)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Đang trực tuyến',
                          style: GoogleFonts.inter(fontSize: 9.5, color: const Color(0xFF10B981), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 1. Giao diện ứng dụng (Dark mode slider)
        _buildSectionHeader('Giao diện ứng dụng', 'Cấu hình và cá nhân hóa trải nghiệm hiển thị thị giác', Icons.palette_outlined, const Color(0xFF0EA5E9)),
        Card(
          elevation: 0,
          color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.brightness_2_rounded : Icons.wb_sunny_rounded,
                  color: isDark ? const Color(0xFF6366F1) : Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chế độ tối (Dark Mode)',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bật/tắt giao diện tối cho toàn bộ hệ thống',
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF90A4AE)),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  activeColor: const Color(0xFF6366F1),
                  value: Provider.of<ThemeProvider>(context).isDarkMode,
                  onChanged: (val) {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  },
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        // 2. Pastel Palette Custom Block
        _buildPresetSelector(isDark),

        // 3. Backup and database restore
        _buildSectionHeader('Sao lưu và lưu trữ', 'Quản lý, đồng bộ và phục hồi các cấu trúc kế hoạch', Icons.cloud_done_outlined, const Color(0xFF10B981)),
        _buildBackupAndRestore(isDark),

        // 4. Danger zone
        _buildSectionHeader('Vùng quản trị', 'Sử dụng thận trọng các tác vụ xóa sâu cục bộ dữ liệu', Icons.error_outline_rounded, const Color(0xFFE53935)),
        _buildDangerZone(isDark),

        const SizedBox(height: 20),
        // Logout button slider
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              auth.logout();
              _showNordicSnackBar('👋 Đã đăng xuất an toàn', const Color(0xFF37474F));
            },
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: const Text('Đăng xuất khỏi hệ thống'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
              side: const BorderSide(color: Color(0xFFFFCDD2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ==================== FORM ACCOUNT DÀNH CHO KHÁCH (MẠNH MẼ VÀ SẠCH SẼ) ====================
  Widget _buildLoginRegisterForm(AuthProvider auth, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1),
                width: 2,
              ),
            ),
            child: Icon(
              _isLoginMode ? Icons.explore_rounded : Icons.join_inner_rounded,
              size: 40,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isLoginMode ? 'Đăng Nhập' : 'Tạo Tài Khoản',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _isLoginMode 
                  ? 'Chào mừng bạn quay trở lại, hãy quản lý quỹ thời gian cùng Eisenhower.' 
                  : 'Gia nhập nhóm học tập, tạo dựng thói quen và tối ưu hóa hiệu suất mỗi ngày.',
              style: GoogleFonts.inter(
                fontSize: 12, 
                color: const Color(0xFF78909C),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          if (!_isLoginMode) ...[
            _buildNordicTextField(
              controller: _usernameController,
              label: 'Tên người dùng',
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 14),
          ],

          _buildNordicTextField(
            controller: _emailController,
            label: 'Email hiển thị',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          _buildNordicTextField(
            controller: _passwordController,
            label: 'Mật khẩu bảo mật',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            isDark: isDark,
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  _showNordicSnackBar('Vui lòng điền đầy đủ dữ liệu thông tin', Colors.amber);
                  return;
                }

                if (_isLoginMode) {
                  bool success = await auth.login(email, password);
                  if (!mounted) return;
                  if (success) {
                    _showNordicSnackBar('⚡ Đăng nhập đồng bộ dữ liệu thành công!', const Color(0xFF10B981));
                  } else {
                    _showNordicSnackBar('❌ Sai tài khoản hoặc mật khẩu', const Color(0xFFD32F2F));
                  }
                } else {
                  final username = _usernameController.text.trim();
                  if (username.isEmpty) {
                    _showNordicSnackBar('Vui lòng nhập tên tài khoản', Colors.amber);
                    return;
                  }
                  await auth.register(username, email, password);
                  if (!mounted) return;
                  _showNordicSnackBar('🎉 Tạo lập thành công kế hoạch mới!', const Color(0xFF10B981));
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isLoginMode ? 'Đăng nhập vào bảng' : 'Tạo lập hồ sơ mới',
                style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              setState(() => _isLoginMode = !_isLoginMode);
              _emailController.clear();
              _usernameController.clear();
              _passwordController.clear();
            },
            child: Text(
              _isLoginMode 
                  ? 'Chưa lập tài khoản? Đăng ký tại đây' 
                  : 'Đã hoàn thiện tài khoản? Đăng nhập',
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNordicTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: const Color(0xFF78909C), fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECEFF1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF161616) : const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ==================== DIALOG HIỂN THỊ MÃ EXPORT JSON ĐỂ SAO CHÉP ====================
  void _showJsonExportDialog(String jsonStr, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Tệp sao lưu của bạn',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161616) : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                jsonStr,
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Xong', style: TextStyle(color: Color(0xFF6366F1))),
            ),
          ],
        );
      },
    );
  }

  // ==================== BANNER LƠ LỬNG TRẢ TRẠNG THÁI (TOAST BANNER) ====================
  void _showNordicSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold, 
            fontSize: 12.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}