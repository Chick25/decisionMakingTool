import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TodoList sample'),
        ),
        body: Center(
          child: SizedBox(
            width: 300,  // Độ rộng của toàn bộ ma trận
            height: 300,
            child: Column( // Thêm Column để bọc 2 hàng
            children: [
              // Hàng 1 (Gồm ô 1 và ô 2)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 246, 2, 2),
                          border: Border.all(color: const Color.fromARGB(255, 246, 2, 2), width: 2),
                        ),
                        child: const Center(child: Text('Emergency and Important', textAlign: TextAlign.center)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          border: Border.all(color: Colors.deepOrangeAccent, width: 2),
                        ),
                        child: const Center(child: Text('Not Emergency but Important', textAlign: TextAlign.center)),
                      ),
                    ),
                  ],
                ),
              ),
              // Hàng 2 (Gồm ô 3 và ô 4)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          border: Border.all(color: Colors.yellowAccent, width: 2),
                        ),
                        child: const Center(child: Text('Emergency but not Important', textAlign: TextAlign.center)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          border: Border.all(color: Colors.purple, width: 2),
                        ),
                        child: const Center(child: Text('Not Emergency and not Important', textAlign: TextAlign.center)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          )
          
        ),
      ),
    );
  }
}