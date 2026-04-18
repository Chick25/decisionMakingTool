import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  String _email = '';
  String _password = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;
  // String get password => _password;

  // Kiểm tra trạng thái khi app khởi động
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username') ?? '';
    _email = prefs.getString('email') ?? '';
    _password = prefs.getString('password') ?? '';
    notifyListeners();
  }

  //Register
  Future<void> register(String email, String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
    await prefs.setString('username', username);
    await prefs.setString('password', password);

    _isLoggedIn = true;
    _email = email;
    _username = username;
    _password = password;
    notifyListeners();
  }

  //Login
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    String savedEmail = prefs.getString('email')?? '';
    String savedPassword = prefs.getString('password')?? '';

    if(savedEmail == email && savedPassword == savedPassword){
      await prefs.setBool('isLogged', true);
      _isLoggedIn = true;
      _email = savedEmail;
      _username = prefs.getString('username') ?? '';
      notifyListeners();
      return true;
    }
  return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _isLoggedIn = false;
    _username = '';
    _email = '';
    _password = '';
    notifyListeners();
  }
}