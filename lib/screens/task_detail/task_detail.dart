// ignore_for_file: use_build_context_synchronously

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/Widgets/input/MSAInput.dart';
import 'package:task_manager/core/firebase/firebase_firestore_services.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/main.dart';

class TaskDetail extends StatefulWidget {
  final TaskModel? task;
  const TaskDetail({super.key, this.task});

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  late final TaskModel task;
  late final TextEditingController titleController, descriptionController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    task = widget.task ?? TaskModel();
    task.duration ??= 0;
    titleController = TextEditingController(text: task.title);
    descriptionController = TextEditingController(text: task.description);
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
        // ElevatedButton(
        //     onPressed: () async {
        //       var a = await FlutterSystemRingtones.getAlarmSounds();
        //       a.forEach((element) {
        //         print(element.toJson());
        //         print('----------------- \n ');
        //       });

        //       FlutterRingtonePlayer().play(
        //         fromFile: a[10].uri,
        //         ios: IosSounds.alarm,
        //         looping: false, // Android only - API >= 28
        //         volume: 0.9, // Android only - API >= 28
        //         asAlarm: true, // Android only - all APIs
        //       );

        //       await Future.delayed(const Duration(seconds: 10))
        //           .then((value) => FlutterRingtonePlayer().stop());
        //     },
        //     child: Icon(Icons.alarm)),
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
                  task.time = DateTime(
                    task.time!.year,
                    task.time!.month,
                    task.time!.day,
                    value.hour,
                    value.minute,
                  );
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
    AndroidAlarmManager.oneShotAt(
        (task.time ?? DateTime.now())
            .subtract(Duration(minutes: task.duration ?? 0)),
        int.tryParse(task.id ?? '1') ?? 1, 
      alarmCallback
    );
    print(
        'alarm setlendi ${int.tryParse(task.id ?? '1') ?? 1} ${(task.time ?? DateTime.now()).subtract(Duration(minutes: task.duration ?? 0))}');
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
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
  print(" Hello, world! isolate= function=");
  FlutterRingtonePlayer().play(
    // fromFile: ,
    android: AndroidSounds.ringtone,
    ios: IosSounds.glass,
    looping: false, // Android only - API >= 28
    volume: 1, // Android only - API >= 28
    asAlarm: true, // Android only - all APIs
  );
  Future.delayed(const Duration(seconds: 30))
      .then((value) => FlutterRingtonePlayer().stop());

      const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
 flutterLocalNotificationsPlugin.show(
    0, 'plain title', 'plain body', notificationDetails,
    payload: 'item x');
  
}
