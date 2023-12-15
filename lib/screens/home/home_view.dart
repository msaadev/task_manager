import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/firebase/firebase_auth_services.dart';
import 'package:task_manager/core/firebase/firebase_firestore_services.dart';

import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/core/routes/navigation_Service.dart';
import 'package:task_manager/screens/auth/signin_view.dart';

import '../../main.dart';
import '../task_detail/alarm_stop_view.dart';
import '../task_detail/task_detail.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<TaskModel> taskList = [];
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTaskList();

    initNotification();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkAlarm();
    });
  }

  initNotification() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          try {
            var data = json.decode(details.payload!);
            var task = TaskModel.fromJson(data);
            NavigationService.instance
                .navigateToPageWidget(page: AlarmStopView(task: task));
          } catch (e) {
            print('samil error == $e');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görev Listesi'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            icon: Icon(isEditing ? Icons.check : Icons.edit),
          ),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Çıkış Yap'),
                        content: const Text(
                            'Çıkış yapmak istediğinize emin misiniz?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('İptal')),
                          TextButton(
                              onPressed: () async {
                                await FirebaseAuthService.instance.signOut();

                                Navigator.pushAndRemoveUntil(context,
                                    CupertinoPageRoute(builder: (context) {
                                  return const SigninView();
                                }), (route) => false);
                              },
                              child: const Text('Çıkış Yap')),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return const TaskDetail();
          })).then((value) {
            if (value != null) {
              setState(() {
                taskList.add(value);
              });
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Görev Ekle'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : taskList.isEmpty
              ? const Center(
                  child: Text('Görev Bulunamadı'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(10),
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: taskList.length,
                  itemBuilder: (context, index) {
                    var item = taskList[index];
                    var date = DateFormat(
                      'dd MMMM yyyy , HH:mm',
                    ).format(item.time ?? DateTime.now());

                    return InkWell(
                      onTap: () {
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (context) {
                          return TaskDetail(task: item);
                        })).then((value) {
                          if (value != null) {
                            setState(() {
                              taskList[index] = value;
                            });
                          }
                        });
                      },
                      child: Row(
                        children: [
                          AnimatedContainer(
                            transform: Matrix4.translationValues(
                                isEditing
                                    ? 0
                                    : -MediaQuery.of(context).size.width,
                                0,
                                0),
                            curve: Curves.easeInOut,
                            width: isEditing ? 50 : 0,
                            duration: const Duration(milliseconds: 500),
                            child: isEditing
                                ? deleteButton(context, index)
                                : const SizedBox(),
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall),
                                Text(date,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                Text(item.description ?? ''),
                              ],
                            ),
                          ))
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget deleteButton(BuildContext context, int index) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Görevi Sil'),
              content: const Text('Görevi silmek istediğinize emin misiniz?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () async {
                    var a = await FirebaseFirestoreServices.instance
                        .deleteTask(taskList[index]);

                    if (a == null) {
                      setState(() {
                        taskList.removeAt(index);
                      });
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(a),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Sil'),
                ),
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.delete),
    );
  }

  fetchTaskList() async {
    setLoading(true);
    await FirebaseFirestoreServices.instance.getTasks().then((value) {
      taskList.clear();
      taskList.addAll(value);
    });
    setLoading(false);
  }

  setLoading([bool? value]) {
    setState(() {
      isLoading = value ?? !isLoading;
    });
  }

  checkAlarm() {
    var task = TaskModel.fromSharedNow;
    if (task != null) {
      if (!task.isDone) {
        NavigationService.instance
            .navigateToPageWidget(page: AlarmStopView(task: task));
      }
      print('hereeee');
    } else {
      print('null');
    }
  }
}
