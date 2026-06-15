
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;

  Box get _box => Hive.box('authbox');

  AuthProvider() {
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    // final _box = await Hive.openBox('authBox');
    _isLoggedIn = _box.get('isLoggedIn', defaultValue: false);
    _username = _box.get('username', defaultValue: '');
    _email = _box.get('email', defaultValue: '');
    // print("DEBUG: Sau khi load, isLoggedIn = $_isLoggedIn");
    notifyListeners();
  }

  // Đăng ký
  Future<void> register(String username, String email, String password) async {
    // final box = await Hive.openBox('authBox');

    await _box.put('isLoggedIn', true);
    await _box.put('username', username);
    await _box.put('email', email.toLowerCase());
    await _box.put('password', password);

    await _box.flush();
    print("Đã thực hiện put. Key email có giá trị: ${_box.get('email')}");
    print("Toàn bộ keys hiện có: ${_box.keys.toList()}");

    _isLoggedIn = true;
    _username = username;
    _email = email.toLowerCase();

    notifyListeners();
  }

  // Đăng nhập
  Future<bool> login(String email, String password) async {
    // final box = await Hive.openBox('authBox');

    final savedEmail = _box.get('email', defaultValue: '').toLowerCase();
    final savedPassword = _box.get('password', defaultValue: '');

    if (savedEmail == email.toLowerCase() && savedPassword == password) {
      await _box.put('isLoggedIn', true);

      _isLoggedIn = true;
      _email = savedEmail;
      _username = _box.get('username', defaultValue: '');

      notifyListeners();
      return true;
    }
    return false;
  }

  // Đăng xuất - Sửa quan trọng ở đây
  Future<void> logout() async {
    // final box = await Hive.openBox('authBox');
    await _box.put('isLoggedIn', false);     // Chỉ đổi trạng thái, KHÔNG clear hết

    _isLoggedIn = false;
    notifyListeners();
  }
}