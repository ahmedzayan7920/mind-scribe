import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/screens/home_screen.dart';
import 'package:flutterfirebase/authentication/login_screen.dart';

late bool isLogin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  isLogin = FirebaseAuth.instance.currentUser != null &&
          FirebaseAuth.instance.currentUser!.emailVerified
      ? true
      : false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xff256d85,
          <int, Color>{
            50: Color(0xff256d85), //10%
            100: Color(0xff256d85), //20%
            200: Color(0xff256d85), //30%
            300: Color(0xff256d85), //40%
            400: Color(0xff256d85), //50%
            500: Color(0xff256d85), //60%
            600: Color(0xff256d85), //70%
            700: Color(0xff256d85), //80%
            800: Color(0xff256d85), //90%
            900: Color(0xff256d85), //100%
          },
        ),
      ),
      home: isLogin ? const HomeScreen() : const LoginScreen(),
    );
  }
}
