import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_constants.dart';
import '../core/app_exceptions.dart' hide ServerException;
import 'task_model.dart';

abstract class TaskService {
  Future<List<Task>> getTasks(String userId, {int limit});
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Stream<List<Task>> watchTasks(String userId);
}

class FirestoreTaskService implements TaskService {
  final FirebaseFirestore _firestore;

  FirestoreTaskService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _tasksRef =>
      _firestore.collection(FirestoreCollections.tasks);

  @override
  Future<List<Task>> getTasks(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _tasksRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to fetch tasks: ${e.message}');
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    try {
      final docRef = _tasksRef.doc();
      final newTask = task.copyWith(id: docRef.id);
      await docRef.set(newTask.toMap());
      return newTask;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create task: ${e.message}');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    try {
      await _tasksRef.doc(task.id).update(task.toMap());
      return task;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update task: ${e.message}');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksRef.doc(taskId).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to delete task: ${e.message}');
    }
  }

  @override
  Stream<List<Task>> watchTasks(String userId) {
    return _tasksRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }
}