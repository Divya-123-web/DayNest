import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';
import 'firebase_service.dart';

/// Reads and writes tasks in Cloud Firestore.
/// Path: users/{uid}/tasks/{taskId}
/// The TaskProvider uses this class; screens never call it directly.
class TaskService {
  /// A live stream of the user's tasks.
  /// It sends a new list every time anything changes: when this phone
  /// changes a task, or when another device does.
  Stream<List<TaskModel>> watchTasks(String uid) {
    return FirebaseService.tasksCollection(uid).snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        return snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
            .toList();
      },
    );
  }

  /// Saves a new task. The task id is used as the document id.
  Future<void> addTask(String uid, TaskModel task) {
    return FirebaseService.tasksCollection(uid).doc(task.id).set(task.toMap());
  }

  /// Saves the changes of an existing task.
  Future<void> updateTask(String uid, TaskModel task) {
    return FirebaseService.tasksCollection(uid).doc(task.id).set(task.toMap());
  }

  /// Deletes a task.
  Future<void> deleteTask(String uid, String taskId) {
    return FirebaseService.tasksCollection(uid).doc(taskId).delete();
  }
}