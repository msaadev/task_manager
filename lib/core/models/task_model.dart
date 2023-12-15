import 'dart:convert';

import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/cache/locale_manager.dart';

class TaskModel {
  String? id;
  DateTime? time;
  String? title;
  String? description;
  Ringtone? music;
  int? duration;
  bool isDone = false;

  TaskModel(
      {this.time,
      this.title,
      this.description,
      this.music,
      this.isDone = false,
      this.duration,
      this.id});

  TaskModel.fromJson(Map<String, dynamic> json) {
    time = json['time'] == null ? null : DateTime.parse(json['time']);
    title = json['title'];
    description = json['description'];
    music = json['music'] == null ? null : Ringtone.fromJson(json['music']);
    duration = json['duration'];
    isDone = json['isDone'] ?? false;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time?.toIso8601String();
    data['title'] = title;
    data['description'] = description;
    data['isDone'] = isDone;
    data['music'] = music?.toJson();
    data['duration'] = duration;
    data['id'] = id;
    return data;
  }

  Future saveToShared() async {
    var date =
        (time ?? DateTime.now()).subtract(Duration(minutes: duration ?? 0));
    isDone = true;

    var formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);

    print(formattedDate + json.encode(toJson()));
    var encoded = json.encode(toJson());
    try {
    await  LocaleManager.instance.setStringValue(formattedDate, encoded.toString());
    } catch (e) {
      print('hata == $e');
    }
  }

  static TaskModel? get fromSharedNow {
    try {
      final DateTime now = DateTime.now();

      var formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

      print(formattedDate);

      var a = LocaleManager.instance.getStringValue(formattedDate);
      if (a.isNotEmpty) {
        print('not null');
        var task = TaskModel.fromJson(json.decode(a));
        return task;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
