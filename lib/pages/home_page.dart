import 'package:flutter/material.dart';
import '../bank_state.dart';

class HomePage extends StatefulWidget {
  final void Function(int)? onJump;

  const HomePage({super.key, this.onJump});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  /// ===============================
  /// 🔥 页面启动时：从 Firestore 云端加载
  /// ===============================
  @override
  void initState() {
    super.initState();
    bank.load().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fixedTotal = bank.deposits.fold<int>(
      0,
      (sum, d) => sum + d.amount,
    );

    final totalAssets = bank.balance + fixedTotal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("資産総覧"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          /// ===============================
          /// 总资产
          /// ===============================
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "総資産残高",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${_yen(totalAssets)} 円",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          /// ===============================
          /// 普通預金（切换 Tab）
          /// ===============================
          ListTile(
            title: const Text("普通預金"),
            subtitle: Text("${_yen(bank.balance)} 円"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              widget.onJump?.call(1); // 普通预金 Tab
            },
          ),

          const Divider(height: 1),

          /// ===============================
          /// 定期預金（切换 Tab）
          /// ===============================
          ListTile(
            title: const Text("定期預金"),
            subtitle: Text("${_yen(fixedTotal)} 円"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              widget.onJump?.call(2); // 定期预金 Tab
            },
          ),

          const Divider(height: 12),

          /// ===============================
          /// 快捷操作
          /// ===============================
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "よく使う操作",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _quickButton(
                  icon: Icons.currency_yen,
                  label: "汇款 / 转账",
                  onTap: () => widget.onJump?.call(3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// ===============================
          /// 通知 / 提示卡片
          /// ===============================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F7F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF006A4E),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "セキュリティ強化のため、一部機能のご利用方法が変更されました。詳細はメニューをご確認ください。",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// ===============================
  /// 快捷按钮
  /// ===============================
  static Widget _quickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF006A4E)),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===============================
  /// 日元格式化
  /// ===============================
  String _yen(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) {
        buf.write(',');
      }
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
