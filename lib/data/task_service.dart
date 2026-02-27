import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskflow/data/task_model.dart';
import '../../core/app_constants.dart';
import '../../core/app_exceptions.dart';

abstract class TaskService {
  Future<List<Task>> getTasks(String userId, {int limit, DocumentSnapshot? lastDoc});
  Future<Task> getTask(String taskId);
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
  Future<List<Task>> getTasks(
      String userId, {
        int limit = 20,
        DocumentSnapshot? lastDoc,
      }) async {
    try {
      Query query = _tasksRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to fetch tasks: ${e.message}');
    }
  }

  @override
  Future<Task> getTask(String taskId) async {
    try {
      final doc = await _tasksRef.doc(taskId).get();
      if (!doc.exists) throw const NotFoundException('Task not found.');
      return Task.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to fetch task: ${e.message}');
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
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }
}