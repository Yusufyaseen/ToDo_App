import 'package:get/get.dart';
import 'package:todo/db/db_helper.dart';
import 'package:todo/models/task.dart';

class TaskController extends GetxController {
  RxList<Task> taskList = <Task>[].obs;

  Future<void> addTask({Task? task}) async {
    await DBHelper.insert(task!);
    getTasks();
  }

  Future<void> deleteTask({int? id}) async {
    await DBHelper.delete(id!);
    getTasks();
  }

  Future<void> deleteAllTasks() async {
    await DBHelper.deleteAll();
    getTasks();
  }

  Future<void> markAsCompleted({int? id}) async {
    await DBHelper.update(id!);
    getTasks();
  }

  Future<void> getTasks() async {
    List<Task> tasks = await DBHelper.getTasks();
    taskList.assignAll(tasks);
  }
}
