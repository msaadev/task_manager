import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:task_manager/core/models/task_model.dart';

class AlarmStopView extends StatefulWidget {
  final TaskModel task;
  const AlarmStopView({super.key, required this.task});

  @override
  State<AlarmStopView> createState() => _AlarmStopViewState();
}

class _AlarmStopViewState extends State<AlarmStopView> {
  late TaskModel taskModel;
  late ShakeDetector detector;

  @override
  void initState() {
    super.initState();
    taskModel = widget.task;
    detector = ShakeDetector.autoStart(onPhoneShake: onPhoneShaked);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var a = TaskModel.fromSharedNow;
      if (a != null) {
      if (a.isDone) {
        Navigator.pop(context);
      }
        
      }
    });
  }

  @override
  void dispose() {
    detector.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(taskModel.title ?? ''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(taskModel.title ?? ''),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                taskModel.isDone = true;
                taskModel.saveToShared();
                FlutterRingtonePlayer().stop();
                AndroidAlarmManager.cancel(
                    int.tryParse(widget.task.id ?? '0') ?? 1);
                exit(0);
              },
              child: const Text('Alarmı Durdur'),
            ),
          ],
        ),
      ),
    );
  }

  void onPhoneShaked() {
    taskModel.isDone = true;
    taskModel.saveToShared();
    FlutterRingtonePlayer().stop();
    AndroidAlarmManager.cancel(int.tryParse(widget.task.id ?? '0') ?? 1);
    exit(0);
  }
}

/// Callback for phone shakes
typedef void PhoneShakeCallback();

/// ShakeDetector class for phone shake functionality
class ShakeDetector {
  /// User callback for phone shake
  final PhoneShakeCallback onPhoneShake;

  /// Shake detection threshold
  final double shakeThresholdGravity;

  /// Minimum time between shake
  final int shakeSlopTimeMS;

  /// Time before shake count resets
  final int shakeCountResetTime;

  /// Number of shakes required before shake is triggered
  final int minimumShakeCount;

  int mShakeTimestamp = DateTime.now().millisecondsSinceEpoch;
  int mShakeCount = 0;

  /// StreamSubscription for Accelerometer events
  StreamSubscription? streamSubscription;

  /// This constructor waits until [startListening] is called
  ShakeDetector.waitForStart({
    required this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
    this.minimumShakeCount = 1,
  });

  /// This constructor automatically calls [startListening] and starts detection and callbacks.
  ShakeDetector.autoStart({
    required this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
    this.minimumShakeCount = 1,
  }) {
    startListening();
  }

  /// Starts listening to accelerometer events
  void startListening() {
    streamSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        double x = event.x;
        double y = event.y;
        double z = event.z;

        double gX = x / 9.80665;
        double gY = y / 9.80665;
        double gZ = z / 9.80665;

        // gForce will be close to 1 when there is no movement.
        double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

        if (gForce > shakeThresholdGravity) {
          var now = DateTime.now().millisecondsSinceEpoch;
          // ignore shake events too close to each other (500ms)
          if (mShakeTimestamp + shakeSlopTimeMS > now) {
            return;
          }

          // reset the shake count after 3 seconds of no shakes
          if (mShakeTimestamp + shakeCountResetTime < now) {
            mShakeCount = 0;
          }

          mShakeTimestamp = now;
          mShakeCount++;

          if (mShakeCount >= minimumShakeCount) {
            onPhoneShake();
          }
        }
      },
    );
  }

  /// Stops listening to accelerometer events
  void stopListening() {
    streamSubscription?.cancel();
  }
}
