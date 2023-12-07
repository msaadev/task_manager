// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/Widgets/input/MSAInput.dart';
import 'package:task_manager/core/firebase/firebase_firestore_services.dart';
import 'package:task_manager/core/models/task_model.dart';

class TaskDetail extends StatefulWidget {
  final TaskModel? task;
  const TaskDetail({super.key, this.task});

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  late final TaskModel task;
  late final TextEditingController titleController, descriptionController;

  @override
  void initState() {
    super.initState();
    task = widget.task ?? TaskModel();
    titleController = TextEditingController(text: task.title);
    descriptionController = TextEditingController(text: task.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var a;
          if (widget.task != null) {
            a = await FirebaseFirestoreServices.instance.updateTask(task);
          } else {
            a = await FirebaseFirestoreServices.instance.addTask(task);
          }

          if (a != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(a),
                backgroundColor: Colors.red,
              ),
            );
            return;
          } else {
            Navigator.pop(context, task);
          }
        },
        icon: const Icon(Icons.check),
        label: Text(widget.task != null ? 'Kaydet' : 'Ekle'),
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
}
