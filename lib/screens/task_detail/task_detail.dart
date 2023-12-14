// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/Widgets/input/MSAInput.dart';
import 'package:task_manager/core/cache/locale_manager.dart';
import 'package:task_manager/core/firebase/firebase_firestore_services.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/main.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskDetail extends StatefulWidget {
  final TaskModel? task;

  const TaskDetail({
    super.key,
    this.task,
  });

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  late final TaskModel task;
  late final TextEditingController titleController, descriptionController;
  bool isLoading = false;
  List<Ringtone> ringtoneList = [];
  Ringtone? selectedRingtone;

  @override
  void initState() {
    super.initState();
    task = widget.task ?? TaskModel();
    task.duration ??= 0;
    titleController = TextEditingController(text: task.title);
    descriptionController = TextEditingController(text: task.description);
    FlutterSystemRingtones.getAlarmSounds().then((value) {
      ringtoneList = value;
      if (widget.task != null) {
        selectedRingtone = task.music;
      } else {
        selectedRingtone = ringtoneList[0];
        task.music = selectedRingtone;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: save,
        icon: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const Icon(Icons.check),
        label: isLoading
            ? const SizedBox()
            : Text(widget.task != null ? 'Kaydet' : 'Ekle'),
      ),
      appBar: AppBar(
        title: Text(task.title ?? 'Görev Ekle'),
      ),
      body: ListView(padding: const EdgeInsets.all(10), children: [
        Form(
            child: Column(
          children: [
            MSAInput(
              controller: titleController,
              label: 'Görev Başlığı',
              radius: 0,
              maxLines: 1,
              onChanged: (p0) {
                task.title = p0;
              },
            ),
            const Divider(),
            MSAInput(
              controller: descriptionController,
              radius: 0,
              onChanged: (p0) {
                task.description = p0;
              },
              label: 'Görev Açıklaması',
              minLines: 3,
              maxLines: 6,
            ),
          ],
        )),
        const Divider(),
        ListTile(
          title: const Text('Tarih Seçiniz'),
          trailing: const Icon(Icons.calendar_month),
          subtitle: Text(
            task.time == null
                ? 'Tarih Seçilmedi'
                : DateFormat('dd MMMM yyyy').format(task.time!),
          ),
          onTap: () {
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            ).then((value) {
              if (value != null) {
                setState(() {
                  task.time = value;
                });
              }
            });
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Saat Seçiniz'),
          subtitle: Text(
            task.time == null
                ? 'Saat Seçilmedi'
                : DateFormat('HH:mm').format(task.time!),
          ),
          trailing: const Icon(Icons.schedule),
          onTap: () {
            showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(task.time ?? DateTime.now()),
            ).then((value) {
              if (value != null) {
                setState(() {
                  task.time = DateTime(task.time!.year, task.time!.month,
                      task.time!.day, value.hour, value.minute, 0, 0, 0);
                });
              }
            });
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Hatırlatma Zamanı Seçiniz'),
          subtitle: Text(
            task.duration == null
                ? 'Hatırlatma Zamanı Seçilmedi'
                : '${task.duration} dakika',
          ),
          trailing: const Icon(Icons.timer),
          onTap: () {
            _showDialog(
              CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32,
                // This sets the initial item.
                scrollController: FixedExtentScrollController(
                  initialItem: task.duration ?? 0,
                ),
                // This is called when selected item is changed.
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    task.duration = selectedItem * 5;
                  });
                },
                children: List<Widget>.generate(5, (int index) {
                  return Center(child: Text('${index * 5} dakika'));
                }),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Alarm Sesi Seçiniz'),
          subtitle: Text(
            task.music == null
                ? 'Alarm Sesi Seçilmedi'
                : '${task.music?.title}',
          ),
          trailing: const Icon(Icons.timer),
          onTap: () {
            _showDialog(CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32,
                // This sets the initial item.
                scrollController: FixedExtentScrollController(
                  initialItem: task.duration ?? 0,
                ),
                // This is called when selected item is changed.
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    task.music = ringtoneList[selectedItem];
                  });
                },
                children: List<Widget>.generate(
                  ringtoneList.length,
                  (int index) => Center(
                    child: Text('${ringtoneList[index].title}'),
                  ),
                )));
          },
        ),
        const Divider(),
        const ListTile()
      ]),
    );
  }

  save() async {
    if (task.title == null || task.title!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Görev Başlığı Boş Olamaz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (task.time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarih Seçiniz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (task.duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatırlatma Zamanı Seçiniz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    var a;
    setLoading(true);
    if (widget.task != null) {
      a = await FirebaseFirestoreServices.instance.updateTask(task);
    } else {
      task.id = ((await FirebaseFirestoreServices.instance.getTaskCount()) + 1)
          .toString();
      a = await FirebaseFirestoreServices.instance.addTask(task);
    }

    setLoading(false);
    if (a != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(a),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else {
      setAlarm();
      Navigator.pop(context, task);
    }
  }

  setAlarm() {
    var date = (task.time ?? DateTime.now())
        .subtract(Duration(minutes: task.duration ?? 0));

    var formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);

    print(formattedDate + json.encode(task.toJson()));
    var encoded = json.encode(task.toJson());
    try {
      LocaleManager.instance.setStringValue(formattedDate, encoded.toString());

      flutterLocalNotificationsPlugin.zonedSchedule(
          1,
          '${task.title}',
          '${task.description}',
          tz.TZDateTime.now(tz.local).add(date.difference(DateTime.now())),
          NotificationDetails(
              android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            playSound: false,
            importance: Importance.max,
            category: AndroidNotificationCategory.alarm,
          )),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: json.encode(task.toJson()),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);

      print(date.toString());

      AndroidAlarmManager.oneShotAt(
          date, int.tryParse(task.id ?? '1') ?? 1, alarmCallback,
          exact: true, wakeup: true, rescheduleOnReboot: true);
    } catch (e) {
      print('hata == $e');
    }
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  setLoading([bool? value]) {
    setState(() {
      isLoading = value ?? !isLoading;
    });
  }
}

@pragma('vm:entry-point')
void alarmCallback() {
  try {
    SharedPreferences.getInstance().then((value) {
      value.reload();
      final DateTime now = DateTime.now();

      var formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

      print(formattedDate);

      var a = value.getString(formattedDate);
      if (a != null && a.isNotEmpty) {
        var task = TaskModel.fromJson(json.decode(a));

        FlutterRingtonePlayer().play(
          fromFile: task.music?.uri ?? '',
          ios: IosSounds.glass,
          looping: false,
          volume: 0.1,
          asAlarm: true,
        );
        Future.delayed(const Duration(minutes: 1))
            .then((value) => FlutterRingtonePlayer().stop());
      } else {}
    });
  } catch (e) {
    print('error == $e');
  }
}
