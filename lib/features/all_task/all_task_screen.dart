
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:todolist/services/task_service.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import 'package:fl_chart/fl_chart.dart';

class AllTaskScreen extends StatefulWidget{
  final List urgentImportant;
  final List notUrgentImportant;
  final List urgentNotImportant;
  final List notUrgentNotImportant;

  const AllTaskScreen({
    super.key,
    required this.urgentImportant,
    required this.notUrgentImportant,
    required this.urgentNotImportant,
    required this.notUrgentNotImportant
  });

  @override
  State<AllTaskScreen> createState() => _AllTaskScreenState();

}

class _AllTaskScreenState extends State<AllTaskScreen>{
  int ?selectedIndex;
  int ?tappedIndex;
  bool isExpended = false;

  @override
  
  Widget build(BuildContext context){
    final taskProvider = Provider.of<TaskProvider>(context);

    final allTasks = [
      ...taskProvider.urgentImportant,
      ...taskProvider.notUrgentImportant,
      ...taskProvider.urgentNotImportant,
      ...taskProvider.notUrgentNotImportant,
    ];

    allTasks.sort((a, b)=>b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('All works'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Stack(
        children: [
          _buildTaskList(allTasks, taskProvider),
          _buildPieChart(taskProvider),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task>allTasks, TaskProvider taskProvider){

     List<Task> currentTasks;
    //  if(isExpended && selectedIndex != null){
    //   if(selectedIndex == 0){
    //     currentTasks = taskProvider.urgentImportant;
    //   }else if(selectedIndex == 1){
    //     currentTasks = taskProvider.notUrgentImportant;
    //   }else if(selectedIndex == 2){
    //     currentTasks = taskProvider.urgentNotImportant;
    //   }else if(selectedIndex == 3){
    //     currentTasks = taskProvider.notUrgentNotImportant;
    //   }
    //  }else{
    //   currentTasks = [
    //   ...taskProvider.urgentImportant,
    //   ...taskProvider.notUrgentImportant,
    //   ...taskProvider.urgentNotImportant,
    //   ...taskProvider.notUrgentNotImportant,
    //   ];
    //  } 

    if (isExpended && tappedIndex != null) {
      if (tappedIndex == 0) currentTasks = [...taskProvider.urgentImportant];
      else if (tappedIndex == 1) currentTasks = [...taskProvider.notUrgentImportant];
      else if (tappedIndex == 2) currentTasks = [...taskProvider.urgentNotImportant];
      else if (tappedIndex == 3) currentTasks = [...taskProvider.notUrgentNotImportant];
      else currentTasks = [];
    } else {
      currentTasks = [...allTasks];
    }
      
    // currentTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    currentTasks.sort((a,b){
      if (a.deadline == null && b.deadline != null) return 1;
      if (a.deadline != null && b.deadline == null) return -1;

      if (a.deadline != null && b.deadline != null){
        return a.deadline!.compareTo(b.deadline!);
      }

      return b.createdAt.compareTo(a.createdAt);

    });
    // final sortedList = currentTasks.toList();
  

    return AnimatedOpacity(
      // opacity: isExpended ? 0.3 : 1.0,
      opacity: isExpended ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      child: Padding(
        // padding: const EdgeInsets.all(12),
        padding: const EdgeInsets.only(left: 400, top: 50, right: 20),
        child: currentTasks.isEmpty? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 80, color: Colors.grey,),
              SizedBox(height: 16),
              Text('No work here', style: TextStyle(fontSize: 18)),
            ],
          ),
        ):
        ListView.builder(
          itemCount: currentTasks.length,
          itemBuilder: (context, index){
            final task = currentTasks[index];
            return Card(
              key: ValueKey('list_$tappedIndex'),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Checkbox(
                  value: task.isDone,
                  onChanged: (value){
                    taskProvider.toggleDone(_getTaskKey(task), task);
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone? TextDecoration.lineThrough:null,
                  ),
                ),
                subtitle: task.deadline != null
                ? Text(
                    'Deadline: ${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}'
                  ):null ,
                trailing: IconButton(
                  onPressed: (){
                    taskProvider.deleteTask(_getTaskKey(task), task);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red)
                ),
              ),
            );
          },
        )
      ),
    );
  }


  Widget _buildPieChart(TaskProvider taskProvider) {
    final sections = [
      taskProvider.urgentImportant.length.toDouble(),
      taskProvider.notUrgentImportant.length.toDouble(),
      taskProvider.urgentNotImportant.length.toDouble(),
      taskProvider.notUrgentNotImportant.length.toDouble(),
    ];

    final colors = [Colors.red, Colors.cyan, Colors.green, Colors.amber];

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutQuart,
      top: 100, // Cố định top hoặc điều chỉnh nhẹ
      // CỐ ĐỊNH VỊ TRÍ KHI EXPANDED
      left: isExpended 
          ? 20 // Vị trí nằm hẳn bên trái khi mở danh sách
          : MediaQuery.of(context).size.width * 0.5 - 155, // Nằm giữa khi thu nhỏ
      
      child: SizedBox(
        width: 310,
        height: 310,
        child: PieChart(
          PieChartData(
            sectionsSpace: 5,
            centerSpaceRadius: 48,
            sections: List.generate(4, (i) {
              return PieChartSectionData(
                value: sections[i] == 0 ? 0.1 : sections[i], // Tránh biểu đồ trống
                color: colors[i],
                title: sections[i].toInt() > 0 ? sections[i].toInt().toString() : '',
                radius: selectedIndex == i ? 120 : 100, // Chỉ phóng to miếng bánh khi hover/tap
                titleStyle: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white,
                ),
              );
            }),
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, PieTouchResponse? response) {

                final int ? currentIndex = response?.touchedSection?.touchedSectionIndex;

                // 1. Xử lý Hover để tạo hiệu ứng phóng to miếng bánh (tăng trải nghiệm UI)
                if (event is FlPointerHoverEvent || event is FlLongPressMoveUpdate) {
                  setState(() {
                    selectedIndex = currentIndex;
                  });
                } 
                // 2. Xử lý Tap để dịch chuyển biểu đồ sang trái và hiện danh sách
                else if (event is FlTapUpEvent) {
                  // final tappedIndex = response?.touchedSection?.touchedSectionIndex;
                  setState(() {
                    if (currentIndex == null || (tappedIndex == currentIndex && isExpended)) {
                      isExpended = false;
                      tappedIndex = null;
                    } else {
                      tappedIndex = currentIndex;
                      isExpended = true;
                    }
                  });
                }
                // 3. Quan trọng: Không reset isExpended ở đây nếu event không hợp lệ
              },
            ),
          ),
        ),
      ),
    );
  }


  String _getTaskKey(Task task){
    if(task.isDone) return TaskService.notUrgentImportantKey;
    return TaskService.urgentImportantKey;
  }
}

