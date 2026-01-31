import 'package:flutter/material.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("汇款 / 转账"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            context,
            icon: Icons.account_balance,
            title: "三井住友あて送金",
            subtitle: "三井住友銀行口座への送金",
          ),
          _card(
            context,
            icon: Icons.swap_horiz,
            title: "他金融機関あて送金",
            subtitle: "他行口座への送金",
          ),
          _card(
            context,
            icon: Icons.star_border,
            title: "登録口座あて送金",
            subtitle: "事前に登録した口座へ送金",
          ),
          _card(
            context,
            icon: Icons.history,
            title: "送金履歴から送金",
            subtitle: "過去の送金履歴から再送金",
          ),
        ],
      ),
    );
  }

  /// ===== 单个入口卡片 =====
  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title は未実装です")),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: const Color(0xFF006A4E),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
