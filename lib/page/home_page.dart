import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/widgets/custom_text_feild.dart';

import '../model/model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TodoTask> _tasks = [];

  final _titleController = TextEditingController();
  final _subTitleController = TextEditingController();

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskStrings = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('my_tasks', taskStrings);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? taskStrings = prefs.getStringList('my_tasks');

    if (taskStrings != null) {
      setState(() {
        _tasks.clear();
        _tasks.addAll(
          taskStrings.map((item) => TodoTask.fromJson(jsonDecode(item))).toList(),
        );
      });
    }
  }

  void isChecked(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone!;
    });
    _saveTasks();
  }

  void addTask() {
    if (_titleController.text.isEmpty || _subTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please fill all the fields", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }
    _tasks.add(
      TodoTask(
        title: _titleController.text.toString().trim(),
        subTitle: _subTitleController.text.toString().trim(),
      ),
    );
    _titleController.clear();
    _subTitleController.clear();
    setState(() {});
    _saveTasks();
  }

  void clearTask() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("All task removed 💪", style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.deepOrange,
    ),
    );
    setState(() {
      _tasks.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text("To-do List", style: TextStyle(fontSize: 22)),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 0.5,
                ),
                color: Color(0xFFFAFAFA).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(controller: _titleController, label: "Title"),
                  SizedBox(height: 15),
                  CustomTextField(
                    controller: _subTitleController,
                    label: "Sub Title",
                  ),

                  SizedBox(height: 20),

                  Row(
                    spacing: 50,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            addTask();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Submit", style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            clearTask();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Clear", style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text("No Data Found"))
                  : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: _tasks[index].isDone! ? Colors.grey[200] : Colors.white70,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withOpacity(0.2))
                      ),
                      child: ListTile(
                        title: Text(_tasks[index].title!, style: TextStyle(fontSize: 18), maxLines: 1,),
                        subtitle: Text(_tasks[index].subTitle!, style: TextStyle(fontSize: 16),),
                        trailing: Checkbox(
                          value: _tasks[index].isDone,
                          onChanged: (value) {
                            isChecked(index);
                          },
                          activeColor: Colors.deepOrange,
                        ),
                      ),
                    ),
                    onDismissed: (direction) {
                      TodoTask removedTask = _tasks[index];
                      setState(() {
                        _tasks.removeAt(index);
                      });

                      _saveTasks();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${removedTask.title} removed from the list"),
                          backgroundColor: Colors.deepOrange,
                          duration: Duration(seconds: 2),
                          action: SnackBarAction(
                            textColor: Colors.yellow,
                            label: "UNDO",
                            key: UniqueKey(),
                            onPressed: () {
                              setState(() {
                                _tasks.insert(index, removedTask);
                              });
                              _saveTasks();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
