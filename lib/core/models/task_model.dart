import 'package:flutter/material.dart';

class TaskModel {
  String id = UniqueKey().toString();
   DateTime? time;
   String? title;
   String? description;
   String? music;
   int? duration;

  TaskModel({
    this.time,
    this.title,
    this.description,
    this.music,
    this.duration,
  });

  TaskModel.fromJson(Map<String, dynamic> json) {
    time = json['time'] == null ? null : DateTime.parse(json['time']);
    title = json['title'];
    description = json['description'];
    music = json['music'];
    duration = json['duration'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time?.toIso8601String();
    data['title'] = title;
    data['description'] = description;
    data['music'] = music;
    data['duration'] = duration;
    data['id'] = id;
    return data;
  }
}
