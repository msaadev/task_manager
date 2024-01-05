
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:task_manager/core/firebase/firebase_auth_services.dart';
import 'package:task_manager/screens/home/home_view.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {

  @override
  void initState() {
    super.initState();
   
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: FlutterLogin(
        title: 'Task Manager',
        theme: LoginTheme(
           
          accentColor: Colors.white,
          pageColorDark: Colors.blue,
          footerBackgroundColor: Colors.blue,
          pageColorLight: Colors.blue,
        ),
        loginAfterSignUp: true,
        onSignup: (p0) async {
          var a = await FirebaseAuthService.instance.signUp(data: p0);
          if (a == null) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const HomeView()));
          } else {
            return a;
          }
        },
        onLogin: (p0) async {
          var a = await FirebaseAuthService.instance.signIn(data: p0);
          if (a == null) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const HomeView()));
          } else {
            return a;
          }
        },
        onRecoverPassword: (p0) {
          FirebaseAuthService.instance.recoverPassword(email: p0);
        },
      ),
    );
  }
}
