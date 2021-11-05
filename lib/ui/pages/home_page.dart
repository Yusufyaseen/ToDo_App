import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/notification_services.dart';
import 'package:todo/services/theme_services.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/task_tile.dart';

import '../theme.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();
  late NotifyHelper notifyHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    _taskController.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            ThemeServices().switchTheme();
            // NotifyHelper().displayNotification(
            //     title: "theme Changed", body: "Comment on it");
            // NotifyHelper().scheduledNotification();
          },
          icon: Icon(
            Get.isDarkMode ? Icons.nightlight_round : Icons.wb_incandescent,
            size: 24,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
          // ? const Icon(Icons.nightlight_round)
          // : const Icon(Icons.wb_incandescent),
        ),
        backgroundColor: context.theme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _taskController.deleteAllTasks();
              notifyHelper.cancelAllNotifications();
            },
            icon: Icon(
              Icons.cleaning_services_rounded,
              size: 24,
              color: Get.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const CircleAvatar(
            backgroundImage: AssetImage('images/person.jpeg'),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          _showTasks(),
        ],
      ),
    );
  }

  Container _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
              const Text(
                "Today",
                style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          MyButton(
              label: "Add Tasks",
              onTap: () async {
                await Get.to(const AddTaskPage());
                _taskController.getTasks();
              }),
        ],
      ),
    );
  }

  Container _addDateBar() {
    return Container(
      height: (SizeConfig.orientation == Orientation.landscape)
          ? SizeConfig.screenHeight * 0.25
          : SizeConfig.screenHeight * 0.14,
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: DatePicker(
        DateTime.now(),
        width: 70,
        height: 100,
        initialSelectedDate: _selectedDate,
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    _taskController.getTasks();
  }

  _showTasks() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 15, bottom: 5),
        child: Obx(() {
          if (_taskController.taskList.isEmpty) {
            return _noTasks();
          } else {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                scrollDirection: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                itemCount: _taskController.taskList.length,
                itemBuilder: (BuildContext ctx, int index) {
                  var task = _taskController.taskList[index];
                  if (task.repeat! == 'Daily' ||
                      task.date == DateFormat.yMd().format(_selectedDate) ||
                      (task.repeat! == 'Weekly' &&
                          _selectedDate
                                      .difference(
                                          DateFormat.yMd().parse(task.date!))
                                      .inDays %
                                  7 ==
                              0) ||
                      (task.repeat! == 'Monthly' &&
                          _selectedDate.day ==
                              DateFormat.yMd().parse(task.date!).day)) {
                    var date = DateFormat.jm().parse(task.startTime!);
                    var time = DateFormat("HH:mm").format(date);
                    int hour = int.parse(time.toString().split(':')[0]);
                    int minute = int.parse(time.toString().split(':')[1]);
                    NotifyHelper().scheduledNotification(hour, minute, task);
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 700),
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () => _showBottomSheet(
                              context,
                              task,
                            ),
                            child: TaskTile(
                              task,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            );
          }
        }),
      ),
    );
  }

  Stack _noTasks() {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const SizedBox(height: 150),
                SvgPicture.asset(
                  'images/task.svg',
                  color: primaryClr.withOpacity(0.7),
                  height: 90,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text(
                    "Hey.! You do not have any tasks yet\n Please add new tasks to make your day productive. ",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  _showBottomSheet(BuildContext ctx, Task task) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: const EdgeInsets.only(left: 7, right: 7),
          padding: const EdgeInsets.all(10),
          width: SizeConfig.screenWidth * 0.2,
          height: task.isCompleted == 1
              ? SizeConfig.screenHeight * 0.3
              : SizeConfig.screenHeight * 0.4,
          child: Column(
            children: [
              task.isCompleted == 1
                  ? Container()
                  : _buildBottomSheet(
                      label: "Task Completed",
                      onTap: () {
                        _taskController.markAsCompleted(id: task.id!);
                        notifyHelper.cancelNotification(task);
                        Get.back();
                      },
                      clr: primaryClr,
                    ),
              _buildBottomSheet(
                label: "Delete Task",
                onTap: () {
                  _taskController.deleteTask(id: task.id!);
                  notifyHelper.cancelNotification(task);
                  Get.back();
                },
                clr: Colors.red[900],
              ),
              Divider(
                color: Get.isDarkMode ? Colors.grey : darkGreyClr,
              ),
              _buildBottomSheet(
                label: "Cancel",
                onTap: () {
                  Get.back();
                },
                clr: primaryClr,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildBottomSheet(
      {required String label,
      required Function() onTap,
      required Color? clr,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          color: clr!,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
