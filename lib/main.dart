import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MainApp());
}

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('TodoList sample'),
//         ),
//         body: Builder(
//           builder: (context){
//             return Center(
//               child: SizedBox(
//                 width: 300,  // Độ rộng của toàn bộ ma trận
//                 height: 300,
//                 child: Column( // Thêm Column để bọc 2 hàng
//                 children: [
//                   // Hàng 1 (Gồm ô 1 và ô 2)
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: InkWell(
//                             onTap: (){
//                               showAddTaskDialog(context, 'Emergency & Important');
//                             },
//                             child: Container(
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 color: const Color.fromARGB(255, 246, 2, 2),
//                                 border: Border.all(color: const Color.fromARGB(255, 246, 2, 2), width: 2),
//                               ),
//                               child: const Center(child: Text('Emergency and Important', textAlign: TextAlign.center)),
//                             ),
//                           )
//                         ),
//                         Expanded(
//                           child: InkWell(
//                             onTap: (){
//                               print('2');
//                             },
//                             child: Container(
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 color: Colors.deepOrangeAccent,
//                                 border: Border.all(color: Colors.deepOrangeAccent, width: 2),
//                               ),
//                               child: const Center(child: Text('Not Emergency but Important', textAlign: TextAlign.center)),
//                             ),
//                           )
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Hàng 2 (Gồm ô 3 và ô 4)
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child:InkWell(
//                             onTap: (){
//                               print('3');
//                             },
//                             child: Container(
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 color: Colors.yellowAccent,
//                                 border: Border.all(color: Colors.yellowAccent, width: 2),
//                               ),
//                               child: const Center(child: Text('Emergency but not Important', textAlign: TextAlign.center)),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: InkWell(
//                             onTap: (){
//                               print('4');
//                             },
//                             child: Container(
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 color: Colors.purple,
//                                 border: Border.all(color: Colors.purple, width: 2),
//                               ),
//                               child: const Center(child: Text('Not Emergency and not Important', textAlign: TextAlign.center)),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )
              
//           );
//           }
//         )

//       ),
//     );
//   }
// }

class MainApp extends StatefulWidget{
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp>{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('TodoList sample'),
          ),
          body: Builder(
            builder: (context){
              return Center(
                child: SizedBox(
                  width: 600,  // Độ rộng của toàn bộ ma trận
                  height: 600,
                  child: Column( // Thêm Column để bọc 2 hàng
                  children: [
                    // Hàng 1 (Gồm ô 1 và ô 2)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                showAddTaskDialog(
                                  context,
                                  'Emergency & Important',
                                  (task){
                                    setState(() {
                                      urgentImportant.add(task);
                                    });
                                  }
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 246, 2, 2),
                                  border: Border.all(color: const Color.fromARGB(255, 246, 2, 2), width: 2),
                                ),
                                child: Column(
                                  children: [
                                    const Text('Emergency and Important'),
                                    Expanded(
                                      child: ListView(
                                        children: urgentImportant.map((task){
                                          return ListTile(
                                            leading: Checkbox(
                                              value: task.isDone,
                                              onChanged: (value) {
                                                setState(() {
                                                  task.isDone = value!;
                                                });
                                              },
                                            ),
                                            title: Text(
                                              task.title,
                                              style: TextStyle(
                                                decoration: task.isDone
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  urgentImportant.remove(task);
                                                });
                                              },
                                            ),
                                          );
                                          
                                        }).toList(),
                                      ),
                                      
                                    ),
                                    
                                  ],
                                  // child: const Center(child: Text('Emergency and Important', textAlign: TextAlign.center)),
                                ),
                              )
                            )
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                showAddTaskDialog(
                                  context,
                                  'Not Emergency but Important',
                                  (task){
                                    setState(() {
                                      notUrgentImportant.add(task);
                                    });
                                  }
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrangeAccent,
                                  border: Border.all(color: Colors.deepOrangeAccent, width: 2),
                                ),
                                child: Column(
                                  children: [
                                    const Text('Not Emergency but Important'),
                                    Expanded(
                                      child: ListView(
                                        children: notUrgentImportant.map((task){
                                          return ListTile(
                                            leading: Checkbox(
                                              value: task.isDone,
                                              onChanged: (value) {
                                                setState(() {
                                                  task.isDone = value!;
                                                });
                                              },
                                            ),
                                            title: Text(
                                              task.title,
                                              style: TextStyle(
                                                decoration: task.isDone
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  urgentImportant.remove(task);
                                                });
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    ),
                                  ],
                                ),
                                // child: const Center(child: Text('Not Emergency but Important', textAlign: TextAlign.center)),
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                    // Hàng 2 (Gồm ô 3 và ô 4)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child:InkWell(
                              onTap: (){
                                showAddTaskDialog(
                                  context,
                                  'Emergency but not Important',
                                  (task){
                                    setState(() {
                                      urgentNotImportant.add(task);
                                    });
                                  }
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.yellowAccent,
                                  border: Border.all(color: Colors.yellowAccent, width: 2),
                                ),
                                child: Column(
                                  children: [
                                    const Text('Emergency but not Important'),
                                    Expanded(
                                      child: ListView(
                                        children: urgentNotImportant.map((task){
                                          return ListTile(
                                            leading: Checkbox(
                                              value: task.isDone,
                                              onChanged: (value) {
                                                setState(() {
                                                  task.isDone = value!;
                                                });
                                              },
                                            ),
                                            title: Text(
                                              task.title,
                                              style: TextStyle(
                                                decoration: task.isDone
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  urgentImportant.remove(task);
                                                });
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    )
                                  ],
                                ),
                                // child: const Center(child: Text('Emergency but not Important', textAlign: TextAlign.center)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                showAddTaskDialog(
                                  context,
                                  'Not Emergency & not Important',
                                  (task){
                                    setState(() {
                                      notUrgentNotImportant.add(task);
                                    });
                                  }
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  border: Border.all(color: Colors.purple, width: 2),
                                ),
                                child: Column(
                                  children: [
                                    const Text('Not Emergency and not Important'),
                                    Expanded(
                                      child: ListView(
                                        children: notUrgentNotImportant.map((task){
                                        return ListTile(
                                          leading: Checkbox(
                                            value: task.isDone,
                                            onChanged: (value) {
                                              setState(() {
                                                task.isDone = value!;
                                              });
                                            },
                                          ),
                                          title: Text(
                                            task.title,
                                            style: TextStyle(
                                              decoration: task.isDone
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                urgentImportant.remove(task);
                                              });
                                            },
                                          ),
                                        );
                                        }).toList(),
                                      )
                                    ),
                                  ],
                                ),
                                // child: const Center(child: Text('Not Emergency and not Important', textAlign: TextAlign.center)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              
            );
          }
        )

      ),
    );
  }
}


void showAddTaskDialog(BuildContext context, String type, Function(Task) onSave){
  TextEditingController controller = TextEditingController();
  bool isDone = false;

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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (){
                  final task = Task(controller.text, isDone);
                  onSave(task);
                  Navigator.pop(context);
                },
                child: Text('Save'),
              )
            ],
          );
        }
      );
    }
  );
}

class Task{
  String title;
  bool isDone;

  Task(this.title, this.isDone);
}

List<Task> urgentImportant = [];
List<Task> notUrgentImportant = [];
List<Task> urgentNotImportant = [];
List<Task> notUrgentNotImportant = [];
