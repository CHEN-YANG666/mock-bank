import 'package:flutter/material.dart';
import '../bank_state.dart';

import 'home_page.dart';
import 'balance_page.dart';
import 'fixed_page.dart';
import 'transfer_page.dart';
import 'household_page.dart';
import 'menu_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    /// ✅ 启动时从 Firebase 云端加载数据
    bank.load().then((_) {
      if (mounted) {
        setState(() {
          _loaded = true;
        });
      }
    });
  }

  void _jumpTo(int i) {
    setState(() {
      _index = i;
    });
  }

  /// ❗ 不能用 const
  late final List<Widget> pages = [
    HomePage(onJump: _jumpTo), // 0 首页
    const BalancePage(),       // 1 普通预金
    FixedPage(),               // 2 定期预金（Stateful，不能 const）
    const TransferPage(),      // 3 汇款 / 转账
    const HouseholdPage(),     // 4 家计管理
    const MenuPage(),          // 5 菜单
  ];

  @override
  Widget build(BuildContext context) {
    /// ⏳ 数据还没加载完，给一个占位
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF006A4E),
          ),
        ),
      );
    }

    return Scaffold(
      body: pages[_index],

      /// ===== 底部导航（常驻）=====
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 72,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              /// ===== 白色底栏 =====
              Container(
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _item(Icons.home, "首页", 0),
                    _item(Icons.account_balance_wallet, "账户一览", 1),

                    const SizedBox(width: 72), // 中央按钮占位

                    _item(Icons.pie_chart_outline, "家计管理", 4),
                    _item(Icons.menu, "菜单", 5),
                  ],
                ),
              ),

              /// ===== 中央凸起：汇款 / 转账 =====
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _jumpTo(3),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF006A4E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.currency_yen,
                          color: Colors.white,
                          size: 26,
                        ),
                        SizedBox(height: 2),
                        Text(
                          "汇款/转账",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== 普通 Tab Item =====
  Widget _item(IconData icon, String label, int i) {
    final selected = _index == i;
    return GestureDetector(
      onTap: () => _jumpTo(i),
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? const Color(0xFF006A4E)
                  : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? const Color(0xFF006A4E)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
