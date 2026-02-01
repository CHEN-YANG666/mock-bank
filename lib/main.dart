import 'package:flutter/material.dart';
import 'pages/shell_page.dart';
import 'bank_state.dart'; // ⬅️ 一定要引入

Future<void> main() async {
  // ✅ Flutter 初始化（Web / Mobile 都需要）
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 关键：先加载本地数据（Web 不 await 会直接 TypeError）
  await bank.load();

  runApp(const MyBankApp());
}

class MyBankApp extends StatelessWidget {
  const MyBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ 保持你原来的银行风格
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
