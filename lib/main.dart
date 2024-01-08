import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:task_manager/core/cache/locale_manager.dart';
import 'package:task_manager/core/routes/navigation_Service.dart';
import 'package:task_manager/screens/auth/signin_view.dart';
import 'package:task_manager/screens/home/home_view.dart';
import 'core/firebase/firebase_auth_services.dart';
import 'package:timezone/data/latest_all.dart' as tz;


AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.high,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('samil background come ${notificationResponse.actionId}');
  if (notificationResponse.actionId != null) {
    try {
      if (notificationResponse.actionId == 'alarm_stop') {
        print('ringtone stopped');
        FlutterRingtonePlayer().stop();
      }
    } catch (e) {
      print('samil error == $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AndroidAlarmManager.initialize();
   tz.initializeTimeZones();
  await initializeDateFormatting('tr', null);
  await LocaleManager.prefrencesInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Görev Yöneticisi',
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
         Locale('tr', 'TR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: NavigationService.instance.navigatorKey,
      home: FirebaseAuthService.instance.isLogged()
          ? const HomeView()
          : const SigninView(),
    );
  }
}
