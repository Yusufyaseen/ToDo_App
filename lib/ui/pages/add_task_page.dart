import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/input_field.dart';
import '../theme.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now());
  String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)));

  int _selectedReminder = 5;
  final List<int> _reminders = [5, 10, 15, 20];
  String _selectedRepeat = 'None';
  final List<String> _repeats = ['None', 'Daily', 'Weekly', 'Monthly'];

  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
          // ? const Icon(Icons.nightlight_round)
          // : const Icon(Icons.wb_incandescent),
        ),
        backgroundColor: context.theme.backgroundColor,
        elevation: 0,
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage('images/person.jpeg'),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Add Task",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InputField(
                title: "Title",
                hint: "Enter a Title here",
                controller: _titleController,
              ),
              InputField(
                title: "Note",
                hint: "Enter a note here",
                controller: _noteController,
              ),
              InputField(
                title: "Date",
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(Icons.date_range_outlined),
                  onPressed: () => _getDateFromUser(),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      title: "Start Time",
                      hint: _startTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_filled_rounded),
                        onPressed: () => _getTimeFromUser(isStartTime: true),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: InputField(
                      title: "End Time",
                      hint: _endTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_filled_rounded),
                        onPressed: () => _getTimeFromUser(isStartTime: false),
                      ),
                    ),
                  ),
                ],
              ),
              InputField(
                title: "Reminder",
                hint: '$_selectedReminder minutes early',
                widget: DropdownButton(
                  value: _selectedReminder,
                  borderRadius: BorderRadius.circular(20),
                  dropdownColor: Colors.blueGrey,
                  items: _reminders
                      .map((value) => DropdownMenuItem(
                            child: Text(
                              "$value",
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: value,
                          ))
                      .toList(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedReminder = newValue!;
                    });
                  },
                ),
              ),
              InputField(
                title: "Repeat",
                hint: _selectedRepeat,
                widget: DropdownButton(
                  value: _selectedRepeat,
                  borderRadius: BorderRadius.circular(20),
                  dropdownColor: Colors.blueGrey,
                  items: _repeats
                      .map((value) => DropdownMenuItem(
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: value,
                          ))
                      .toList(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRepeat = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _codePalette(),
                  MyButton(
                    label: "Create Task",
                    onTap: () {
                      _validateDate();
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _validateDate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDb();
      Get.back();
    } else {
      Get.snackbar(
        "Required",
        "All fields are required",
        backgroundColor: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        colorText: pinkClr,
        icon: const Icon(
          Icons.warning,
          color: Colors.red,
        ),
      );
    }
  }

  _addTaskToDb() async {
    await _taskController.addTask(
      task: Task(
        title: _titleController.text,
        note: _noteController.text,
        isCompleted: 0,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        remind: _selectedReminder,
        repeat: _selectedRepeat,
      ),
    );
  }

  Column _codePalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Color",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          children: List<Widget>.generate(
            3,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: 15,
                  child: (_selectedColor == index)
                      ? const Icon(
                          Icons.done,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                  backgroundColor: (index == 0)
                      ? primaryClr
                      : (index == 1)
                          ? pinkClr
                          : orangeClr,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _getDateFromUser() async {
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2018),
      lastDate: DateTime(2050),
    );

    if (_pickedDate != null) {
      setState(() {
        _selectedDate = _pickedDate;
      });
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? _pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(
              DateTime.now().add(const Duration(minutes: 15)),
            ),
    );
    if (_pickedTime != null) {
      String formattedTime = _pickedTime.format(context);
      isStartTime
          ? setState(() {
              _startTime = formattedTime;
            })
          : setState(() {
              _endTime = formattedTime;
            });
    }
  }
}
