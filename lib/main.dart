import 'package:flutter/material.dart';
import 'models/task.dart';
import 'widgets/quadrant.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/all_task/all_task_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget{
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp>{
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context){
    return MaterialApp(

      theme: ThemeData(
        fontFamily: 'Poppins',        // tên font family
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),

        home: Scaffold(
          appBar: AppBar(

            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            toolbarHeight: 100,
          
              title: const Text(
                'Decision Making List',
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
          ),
          body: Row(
            
            children:[
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
                },
                minExtendedWidth: 220,
                minWidth: 90,
                
                labelType: NavigationRailLabelType.selected,
                backgroundColor: const Color.fromARGB(255, 34, 42, 62),
                indicatorColor: const Color.fromARGB(255, 201, 201, 201).withValues(alpha: 0.5),
                selectedIconTheme: const IconThemeData(color: Color.fromARGB(255, 243, 243, 243)),
                unselectedIconTheme: IconThemeData(color: const Color.fromARGB(255, 216, 216, 216)),
                selectedLabelTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 201, 201, 201),
                ),
                // elevation: 2,

                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.grid_on),
                    selectedIcon: Icon(Icons.grid_on_rounded),
                    label: Text('Matrix'),
                    
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.list_alt),
                    selectedIcon: Icon(Icons.list_alt_rounded),
                    label: Text('All Tasks'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.check_circle_outline),
                    selectedIcon: Icon(Icons.check_circle),
                    label: Text('Completed'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.today_outlined),
                    selectedIcon: Icon(Icons.today),
                    label: Text('Today'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),

              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
    );   
  }

  Widget _buildMatrixArea(){
    return Builder(
      builder: (context){
        return Center(
          child: Container(
            height: 850,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
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
          ),
        );
      }
    );
  }

  Widget _buildBody(){
    switch(_selectedIndex){
      case 0:
        return _buildMatrixArea();
      case 1:
        return AllTaskScreen(
          urgentImportant: urgentImportant,
          notUrgentImportant: notUrgentImportant,
          urgentNotImportant: urgentNotImportant,
          notUrgentNotImportant: notUrgentNotImportant,
        );
      default:
        return _buildMatrixArea();
    }
  }

}

void showAddTaskDialog(BuildContext context, String type, Function(Task) onSave){
  TextEditingController controller = TextEditingController();
  bool isDone = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () async{
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if(date !=null){
                      setState((){
                        selectedDate = date;
                      });
                    }
                  },
                  child: Text(
                    selectedDate == null ? "Select date" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                  ),
                ),

                TextButton(
                  onPressed: () async{
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if(time!=null){
                      setState((){
                        selectedTime = time;
                      });
                    }
                  },
                  child: Text(
                    selectedTime == null ? "Select time" : "${selectedTime!.hour}:${selectedTime!.minute}",
                  ),
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
                  DateTime? deadline;

                  if(selectedDate != null && selectedTime !=null){
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
                    deadline: deadline
                  );
                  onSave(task);
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
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
