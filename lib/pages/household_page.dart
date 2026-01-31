import 'package:flutter/material.dart';
import '../bank_state.dart';

class HouseholdPage extends StatelessWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final monthlyTx = bank.transactions.where((t) {
      return t.date.year == now.year &&
          t.date.month == now.month &&
          t.amount < 0; // 支出のみ
    }).toList();

    final totalExpense =
        monthlyTx.fold<int>(0, (sum, t) => sum + t.amount.abs());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("家計管理"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          /// ===== 今月の収支 =====
          _sectionTitle("今月の支出"),
          _summaryCard(totalExpense),

          const Divider(height: 24),

          /// ===== カテゴリー別 =====
          _sectionTitle("カテゴリー別支出"),
          _categoryRow("食費", totalExpense * 0.25 ~/ 1),
          _categoryRow("住居", totalExpense * 0.45 ~/ 1),
          _categoryRow("交通", totalExpense * 0.10 ~/ 1),
          _categoryRow("その他", totalExpense * 0.20 ~/ 1),

          const Divider(height: 24),

          /// ===== 最近の支出 =====
          _sectionTitle("最近の支出"),
          if (monthlyTx.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "今月の支出はありません",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...monthlyTx.take(5).map(_expenseRow),
        ],
      ),
    );
  }

  /// ================= UI =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _summaryCard(int expense) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Text(
              "支出合計",
              style: TextStyle(color: Colors.black54),
            ),
            const Spacer(),
            Text(
              "-${_yen(expense)} 円",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryRow(String name, int amount) {
    return ListTile(
      title: Text(name),
      trailing: Text(
        "-${_yen(amount)} 円",
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _expenseRow(BankTransaction t) {
    return ListTile(
      dense: true,
      title: Text(t.description),
      subtitle: Text("${t.date.month}/${t.date.day}"),
      trailing: Text(
        "-${_yen(t.amount.abs())} 円",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

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
