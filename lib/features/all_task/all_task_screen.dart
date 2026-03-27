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

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildSections(),
              pieTouchData: PieTouchData(
                touchCallback: (event, response){
                  if(response != null && response.touchedSection != null) {
                    setState(() {
                      selectedIndex = response.touchedSection!.touchedSectionIndex;
                    });
                  }
                },
              )
            ),
          ),
        ), 

        Expanded(
          child: selectedIndex == null ? Center(child: Text('Select in pie chart'))
          : ListView(
            children: _getSelectedTasks().map((task){
              return Card(
                child: ListTile(
                  title: Text(task.title),
                ),
              );
            }).toList(),
          ),
        ),

      ],
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


