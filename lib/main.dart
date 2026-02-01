import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase 初始化（Web）
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAabNJEJkWsQE5mVcYqc4ANo9vBmcH-VIc",
      authDomain: "mock-bank-37875.firebaseapp.com",
      projectId: "mock-bank-37875",
      storageBucket: "mock-bank-37875.appspot.com",
      messagingSenderId: "411423265063",
      appId: "1:411423265063:web:c05cb769da193ac081d902",
    ),
  );

  runApp(const MyBankApp());
}

class MyBankApp extends StatelessWidget {
  const MyBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        useMaterial3: false,
      ),
      home: const ShellPage(),
    );
  }
}
