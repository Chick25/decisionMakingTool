import 'package:flutter/material.dart';
// import 'package:stack_chart/stack_chart.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:todolist/main.dart';
// import 'package:todolist/models/task.dart';

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
  bool isExpended = false;

  @override
  Widget build(BuildContext context){
    return SizedBox.expand( 
      child:Stack(

        children: [
          _buildTaskList(),
          _buildPieChart(),
          // _buildTaskList(),
        ],
      ),
    );
  }

  Widget _buildPieChart(){
    return AnimatedPositioned(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,

      top: isExpended ? 200 : 150,
      left: isExpended ? 60 : 550,

      child: AnimatedScale(
        scale: isExpended? 0.9 : 1.5,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOutQuint,

        child: SizedBox(
        width: isExpended ? 200 : 300,
        height: isExpended ? 200 : 300,

        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: _buildSections(),
            pieTouchData: PieTouchData(
              
              touchCallback: (event, response){
                
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.touchedSection == null) {
                  return;
                }

                if(event is FlTapUpEvent){

                // if(event.isInterestedForInteractions && response != null && response.touchedSection != null) {
                  setState(() {

                    int tappedIndex = response.touchedSection!.touchedSectionIndex;

                    if(selectedIndex == tappedIndex && isExpended){
                      isExpended = false;
                      selectedIndex = null;
                    }else{
                      selectedIndex = tappedIndex;
                      isExpended = true;
                     
                    }
                  });
                }

                if (event is FlPointerHoverEvent) {
                  setState(() {
                    selectedIndex =
                        response.touchedSection?.touchedSectionIndex;
                  });
                }

              }
                
            
            )
          ),
        ),
      ),
      )
    );
  }

  Widget _buildTaskList(){
    return AnimatedOpacity(
      duration: Duration(milliseconds: 400),
      opacity: isExpended ? 1 : 0,

      child: Padding(
        padding: const EdgeInsets.only(left: 400, top: 50, right: 20),
          child: selectedIndex == null 
          ? SizedBox() : ListView(
              children: _getSelectedTasks().map((task){
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(task.title),
                  ),
                );
              }).toList(),
          ),
      ),
    );
  }


  List<PieChartSectionData> _buildSections(){
    final data = [
      widget.urgentImportant.length.toDouble(),
      widget.notUrgentImportant.length.toDouble(),
      widget.urgentNotImportant.length.toDouble(),
      widget.notUrgentNotImportant.length.toDouble(),
    ];

    final colors = [
      Colors.red,
      Color.fromARGB(255, 12, 206, 240),
      Color.fromARGB(255, 15, 255, 31),
      Color.fromARGB(255, 255, 238, 0),
    ];

    return List.generate(4, (index){
      return PieChartSectionData(
        value: data[index],
        color: colors[index],
        title: data[index].toInt().toString(),
        radius: selectedIndex == index ? 110  : 90,
      );
    });
  }

  List _getSelectedTasks(){
    switch (selectedIndex){
      case 0:
        return widget.urgentImportant;
      case 1:
        return widget.notUrgentImportant;
      case 2:
        return widget.urgentNotImportant;
      case 3: 
        return widget.notUrgentNotImportant;
      default:
        return [];
    }

  }

}


