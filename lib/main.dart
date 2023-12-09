import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/screens/auth/signin_view.dart';
import 'package:task_manager/screens/home/home_view.dart';
import 'core/firebase/firebase_auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AndroidAlarmManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Görev Yöneticisi',
      locale: const Locale('tr', 'TR'),
      home: FirebaseAuthService.instance.isLogged()
          ? const HomeView()
          : const SigninView(),
    );
  }
}
