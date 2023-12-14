import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shake/shake.dart';
import 'package:task_manager/core/models/task_model.dart';

class AlarmStopView extends StatefulWidget {
  final TaskModel task;
  const AlarmStopView({super.key, required this.task});

  @override
  State<AlarmStopView> createState() => _AlarmStopViewState();
}

class _AlarmStopViewState extends State<AlarmStopView> {
  @override
  void initState() {
    super.initState();
    ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
      widget.task.isDone = true;
      widget.task.saveToShared();
      FlutterRingtonePlayer().stop();
      AndroidAlarmManager.cancel(int.tryParse(widget.task.id ?? '0') ?? 1);
      exit(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title ?? ''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.task.title ?? ''),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.task.isDone = true;
                widget.task.saveToShared();
                FlutterRingtonePlayer().stop();
                AndroidAlarmManager.cancel(
                    int.tryParse(widget.task.id ?? '0') ?? 1);
                exit(0);
              },
              child: const Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
