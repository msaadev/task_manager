import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';

class TaskModel {
  String? id ;
   DateTime? time;
   String? title;
   String? description;
   Ringtone? music;
   int? duration;

  TaskModel({
    this.time,
    this.title,
    this.description,
    this.music,
    this.duration,
    this.id
  });

  TaskModel.fromJson(Map<String, dynamic> json) {
    time = json['time'] == null ? null : DateTime.parse(json['time']);
    title = json['title'];
    description = json['description'];
    music = json['music'] == null ? null : Ringtone.fromJson(json['music']);
    duration = json['duration'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time?.toIso8601String();
    data['title'] = title;
    data['description'] = description;
    data['music'] = music?.toJson();
    data['duration'] = duration;
    data['id'] = id;
    return data;
  }
}
