import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:task_manager/core/models/task_model.dart';

class FirebaseFirestoreServices {
  static FirebaseFirestoreServices? _instance;
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  static FirebaseFirestoreServices get instance {
    _instance ??= FirebaseFirestoreServices._init();
    return _instance!;
  }

  FirebaseFirestoreServices._init() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  Future<String?> addTask(TaskModel task) async {
    try {
      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Tasks')
          .doc(task.id)
          .set(task.toJson());
      return null;
    } catch (e) {
      if (e is FirebaseException) {
        return e.message;
      } else {
        return 'Bir hata oluştu';
      }
    }
  }

  Future<String?> updateTask(TaskModel task) async {
    try {
      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Tasks')
          .doc(task.id)
          .update(task.toJson());

      return null;
    } catch (e) {
      if (e is FirebaseException) {
        return e.message;
      } else {
        return 'Bir hata oluştu';
      }
    }
  }

  Future<String?> deleteTask(TaskModel task) async {
    try {
      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Tasks')
          .doc(task.id)
          .delete();

      return null;
    } catch (e) {
      if (e is FirebaseException) {
        return e.message;
      } else {
        return 'Bir hata oluştu';
      }
    }
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      var request = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Tasks')
          .get();

      return request.docs
          .map((e) => TaskModel.fromJson(e.data()))
          .toList(growable: false);
    } catch (e) {
      if (e is FirebaseException) {
        return [];
      } else {
        return [];
      }
    }
  }

  Future<int> getTaskCount() async {
    try {
      var request = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .get();

      var id = request.data()?['taskCount'];

      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .set({'taskCount': id == null ? 0 : id + 1});

      print('$id id');

      if (id != null) {
        return id;
      }

      return 0;
    } catch (e) {
      if (e is FirebaseException) {
        return 0;
      } else {
        return 0;
      }
    }
  }
}
