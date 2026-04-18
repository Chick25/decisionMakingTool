// import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class AuthProvider extends ChangeNotifier {
//   bool _isLoggedIn = false;
//   String _username = '';
//   String _email = '';
//   // String _password = '';

//   bool get isLoggedIn => _isLoggedIn;
//   String get username => _username;
//   String get email => _email;
//   // String get password => _password;

//   AuthProvider(){
//     // checkLoginStatus();
//     _loadAuth();
//   }

//   // Kiểm tra trạng thái khi app khởi động
//   // Future<void> checkLoginStatus() async {
//   //   try{
//   //     final prefs = await SharedPreferences.getInstance();
//   //     _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//   //     _username = prefs.getString('username') ?? '';
//   //     _email = prefs.getString('email') ?? '';
//   //     _password = prefs.getString('password') ?? '';
//   //     notifyListeners();
//   //   } catch(e){
//   //     print('Lỗi load auth: $e');
//   //   }
//   // }

//   Future<void> _loadAuth() async{
//     try{
//       final box = await Hive.openBox('authBox');

//       _isLoggedIn = box.get('isLoggedIn', defaultValue: false);
//       _username = box.get('username', defaultValue: '');
//       _email = box.get('email', defaultValue: '');
//       // _password = box.get('password', defaultValue: '');

//       notifyListeners();
//     }catch(e){
//       print('Lỗi load Auth từ Hive: $e');
//     }
//   }

//   //Register
//   Future<void> register(String email, String username, String password) async {
//     // final prefs = await SharedPreferences.getInstance();
//     // await prefs.setBool('isLoggedIn', true);
//     // await prefs.setString('email', email);
//     // await prefs.setString('username', username);
//     // await prefs.setString('password', password);
//     final box = await Hive.openBox('authBox');

//     await box.put('isLoggedIn', true);
//     await box.put('username', username);
//     await box.put('email', email);
//     await box.put('password', password);

//     _isLoggedIn = true;
//     _email = email;
//     _username = username;
//     _password = password;
//     notifyListeners();
//   }

//   //Login
//   Future<bool> login(String email, String password) async {
//     // final prefs = await SharedPreferences.getInstance();

//     // String savedEmail = prefs.getString('email')?? '';
//     // String savedPassword = prefs.getString('password')?? '';
//     final box = await Hive.openBox('authBox');

//     String savedEmail = box.get('email', defaultValue: '');
//     String savedPassword = box.get('password', defaultValue: '');


//     if(savedEmail.isNotEmpty && savedEmail == email && savedPassword == savedPassword){
//       // await prefs.setBool('isLogged', true);
//       await box.put('isLoggedIn', true);
//       _isLoggedIn = true;
//       _email = savedEmail;
//       // _username = prefs.getString('username') ?? '';
//       _username = box.get('username', defaultValue: '');
//       notifyListeners();
//       return true;
//     }
//   return false;
//   }

//   Future<void> logout() async {
//     // final prefs = await SharedPreferences.getInstance();
//     final box = await Hive.openBox('authBox');
//     await box.put('isLoggedIn', false);

//     _isLoggedIn = false;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;

  AuthProvider() {
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final box = await Hive.openBox('authBox');
    _isLoggedIn = box.get('isLoggedIn', defaultValue: false);
    _username = box.get('username', defaultValue: '');
    _email = box.get('email', defaultValue: '');
    notifyListeners();
  }

  // Đăng ký
  Future<void> register(String username, String email, String password) async {
    final box = await Hive.openBox('authBox');

    await box.put('isLoggedIn', true);
    await box.put('username', username);
    await box.put('email', email.toLowerCase());
    await box.put('password', password);

    _isLoggedIn = true;
    _username = username;
    _email = email.toLowerCase();

    notifyListeners();
  }

  // Đăng nhập
  Future<bool> login(String email, String password) async {
    final box = await Hive.openBox('authBox');

    final savedEmail = box.get('email', defaultValue: '').toLowerCase();
    final savedPassword = box.get('password', defaultValue: '');

    if (savedEmail == email.toLowerCase() && savedPassword == password) {
      await box.put('isLoggedIn', true);

      _isLoggedIn = true;
      _email = savedEmail;
      _username = box.get('username', defaultValue: '');

      notifyListeners();
      return true;
    }
    return false;
  }

  // Đăng xuất - Sửa quan trọng ở đây
  Future<void> logout() async {
    final box = await Hive.openBox('authBox');
    await box.put('isLoggedIn', false);     // Chỉ đổi trạng thái, KHÔNG clear hết

    _isLoggedIn = false;
    notifyListeners();
  }
}