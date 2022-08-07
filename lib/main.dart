import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/screens/home_screen.dart';
import 'package:flutterfirebase/screens/login_screen.dart';

late bool isLogin;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  isLogin = FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified ? true: false;
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
        primarySwatch: Colors.blue,
      ),
      home: isLogin? const HomeScreen() : const LoginScreen(),
    );
  }
}

