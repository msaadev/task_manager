import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:task_manager/core/models/task_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Task> taskList = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    taskList = [
      Task(
        time: DateTime.now(),
        title: 'Flutter Öğren',
        description: 'Flutter öğrenmeye başla',
        music: 'https://www.bensound.com/bensound-music/bensound-summer.mp3',
        duration: 20,
      ),
      Task(
        time: DateTime.now().add(const Duration(hours: 1)),
        title: 'Flutter Öğren',
        description: 'Flutter öğrenmeye başla 2',
        music: 'https://www.bensound.com/bensound-music/bensound-summer.mp3',
        duration: 30,
      ),
      Task(
        time: DateTime.now().add(const Duration(hours: 2)),
        title: 'Flutter Öğren',
        description: 'Flutter öğrenmeye başla 3',
        music: 'https://www.bensound.com/bensound-music/bensound-summer.mp3',
        duration: 40,
      ),
    ];
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Görev Ekle'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView.separated(
        padding: EdgeInsets.all(10),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          var item = taskList[index];
          var date = DateFormat(
            'dd MMMM yyyy , hh:mm',
          ).format(item.time ?? DateTime.now());

          return Row(
            children: [
              AnimatedContainer(
                transform: Matrix4.translationValues(
                    isEditing ? 0 : -MediaQuery.of(context).size.width, 0, 0),
                curve: Curves.easeInOut,
                width: isEditing ? 50 : 0,
                duration: const Duration(milliseconds: 500),
                child:
                    isEditing ? deleteButton(context, index) : const SizedBox(),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title!,
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(date, style: Theme.of(context).textTheme.bodySmall),
                    Text(item.description!),
                  ],
                ),
              ))
            ],
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
                  onPressed: () {
                    setState(() {
                      taskList.removeAt(index);
                    });
                    Navigator.pop(context);
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
}
