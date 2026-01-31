import 'package:flutter/material.dart';
import '../bank_state.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByMonth(bank.transactions);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("取引明細"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: grouped.isEmpty
          ? const Center(
              child: Text(
                "取引履歴はありません",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView(
              children: grouped.entries.map((entry) {
                final ym = entry.key; // yyyy-MM
                final list = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ===== 月ヘッダー =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: const Color(0xFFF2F2F2),
                      child: Text(
                        _formatYM(ym),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    /// ===== 明細 =====
                    ...list.map(_row).toList(),
                  ],
                );
              }).toList(),
            ),
    );
  }

  /// ===============================
  /// 单条明细
  /// ===============================
  Widget _row(BankTransaction t) {
    final isPlus = t.amount > 0;

    return ListTile(
      dense: true,
      title: Text(
        t.description,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        "${t.date.month}/${t.date.day}",
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        "${isPlus ? '+' : '-'}${_yen(t.amount.abs())} 円",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isPlus ? const Color(0xFF006A4E) : Colors.redAccent,
        ),
      ),
    );
  }

  /// ===============================
  /// 按年月分组
  /// ===============================
  Map<String, List<BankTransaction>> _groupByMonth(
      List<BankTransaction> list) {
    final Map<String, List<BankTransaction>> map = {};

    for (final t in list) {
      final key =
          "${t.date.year}-${t.date.month.toString().padLeft(2, '0')}";

      map.putIfAbsent(key, () => []);
      map[key]!.add(t);
    }

    // 每个月内：日期倒序
    for (final v in map.values) {
      v.sort((a, b) => b.date.compareTo(a.date));
    }

    // 月份整体倒序（3月 → 2月）
    final sortedKeys = map.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return {
      for (final k in sortedKeys) k: map[k]!,
    };
  }

  /// ===============================
  /// UI helpers
  /// ===============================
  String _formatYM(String ym) {
    final parts = ym.split('-');
    return "${parts[0]}年${int.parse(parts[1])}月";
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
