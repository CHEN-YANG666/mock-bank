import 'package:flutter/material.dart';
import 'transaction_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("メニュー"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          /// ===============================
          /// 用户信息卡片
          /// ===============================
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF006A4E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "ログイン中",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "CHEN YANG",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "普通預金 口座番号：19988071",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          /// ===== 口座・取引 =====
          _sectionTitle("口座・取引"),

          _menuItem(
            icon: Icons.receipt_long,
            title: "取引明細",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionPage(),
                ),
              );
            },
          ),
          _divider(),

          _menuItem(
            icon: Icons.currency_exchange,
            title: "振込・送金",
            onTap: () {},
          ),

          _divider(height: 8),

          /// ===== 资产管理 =====
          _sectionTitle("資産管理"),

          _menuItem(
            icon: Icons.account_balance,
            title: "定期預金",
            onTap: () {},
          ),
          _divider(),

          _menuItem(
            icon: Icons.pie_chart_outline,
            title: "家計管理",
            onTap: () {},
          ),

          _divider(height: 8),

          /// ===== 卡 & 服务 =====
          _sectionTitle("カード・サービス"),

          _menuItem(
            icon: Icons.credit_card,
            title: "デビットカード",
            onTap: () {},
          ),
          _divider(),

          _menuItem(
            icon: Icons.notifications_none,
            title: "通知設定",
            onTap: () {},
          ),

          _divider(height: 8),

          /// ===== 设置 / 其他 =====
          _sectionTitle("その他"),

          _menuItem(
            icon: Icons.settings,
            title: "設定",
            onTap: () {},
          ),
          _divider(),

          _menuItem(
            icon: Icons.help_outline,
            title: "ヘルプ・お問い合わせ",
            onTap: () {},
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// ===============================
  /// Section Title
  /// ===============================
  Widget _sectionTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      color: const Color(0xFFF5F5F5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ===============================
  /// Menu Item
  /// ===============================
  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF006A4E),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _divider({double height = 1}) {
    return Divider(
      height: height,
      thickness: height == 1 ? 1 : 0,
    );
  }
}
