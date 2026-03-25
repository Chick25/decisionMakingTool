import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'models/task.dart';
import 'widgets/quadrant.dart';

void main() {
  runApp(const MainApp());
}

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

            backgroundColor: const Color.fromARGB(255, 215, 225, 215),
            foregroundColor: const Color.fromARGB(255, 75, 75, 75),
            // elevation: 4,
            shadowColor: Colors.black54,
            toolbarHeight: 70,

              title: const Text(
                'DecisionMakingList',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              
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
                          QuadrantWidget(
                            title: 'Emergency & Important',
                            color: Colors.red,
                            tasks: urgentImportant,
                            onAdd: () {
                              showAddTaskDialog(context, 'Emergency & Important', (task) {
                                setState(() {
                                  urgentImportant.add(task);
                                });
                              });
                            },
                            onToggle: (task) {
                              setState(() {
                                task.isDone = !task.isDone;
                              });
                            },
                            onDelete: (task) {
                              setState(() {
                                urgentImportant.remove(task);
                              });
                            },
                          ),
                          QuadrantWidget(
                            title: 'Not Emergency but Important',
                            color: const Color.fromARGB(255, 12, 206, 240),
                            tasks: notUrgentImportant,
                            onAdd: () {
                              showAddTaskDialog(context, 'Not Emergency but Important', (task) {
                                setState(() {
                                  notUrgentImportant.add(task);
                                });
                              });
                            },
                            onToggle: (task) {
                              setState(() {
                                task.isDone = !task.isDone;
                              });
                            },
                            onDelete: (task) {
                              setState(() {
                                notUrgentImportant.remove(task);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Hàng 2 (Gồm ô 3 và ô 4)
                    Expanded(
                      child: Row(
                        children: [
                          QuadrantWidget(
                            title: 'Emergency but not Important',
                            color: const Color.fromARGB(255, 15, 255, 31),
                            tasks: urgentNotImportant,
                            onAdd: () {
                              showAddTaskDialog(context, 'Emergency but not Important', (task) {
                                setState(() {
                                  urgentNotImportant.add(task);
                                });
                              });
                            },
                            onToggle: (task) {
                              setState(() {
                                task.isDone = !task.isDone;
                              });
                            },
                            onDelete: (task) {
                              setState(() {
                                urgentNotImportant.remove(task);
                              });
                            },
                          ),
                          QuadrantWidget(
                            title: 'Not Emergency & not Important',
                            color: const Color.fromARGB(255, 255, 238, 0),
                            tasks: notUrgentNotImportant,
                            onAdd: () {
                              showAddTaskDialog(context, 'Not Emergency & not Important', (task) {
                                setState(() {
                                  notUrgentNotImportant.add(task);
                                });
                              });
                            },
                            onToggle: (task) {
                              setState(() {
                                task.isDone = !task.isDone;
                              });
                            },
                            onDelete: (task) {
                              setState(() {
                                notUrgentNotImportant.remove(task);
                              });
                            },
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

List<Task> urgentImportant = [];
List<Task> notUrgentImportant = [];
List<Task> urgentNotImportant = [];
List<Task> notUrgentNotImportant = [];
