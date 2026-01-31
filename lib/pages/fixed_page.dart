import 'package:flutter/material.dart';
import '../bank_state.dart';
import 'fixed_detail_page.dart';

class FixedPage extends StatefulWidget {
  const FixedPage({super.key});

  @override
  State<FixedPage> createState() => _FixedPageState();
}

class _FixedPageState extends State<FixedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ===== AppBar =====
      appBar: AppBar(
        title: const Text("定期預金"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      /// ===== 内容 =====
      body: bank.deposits.isEmpty
          ? const Center(
              child: Text(
                "現在ご利用中の定期預金はありません",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: bank.deposits.length,
              itemBuilder: (context, index) {
                final d = bank.deposits[index];
                final no = (index + 1).toString().padLeft(4, '0');

                return InkWell(
                  onTap: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FixedDetailPage(deposit: d),
                      ),
                    );

                    /// ✅ 解约等操作后刷新
                    if (changed == true) {
                      setState(() {});
                    }
                  },
                  child: Column(
                    children: [
                      /// ===== 灰色信息条 =====
                      Container(
                        color: const Color(0xFFF2F2F2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${_date(d.startDate)} 〜 ${_date(d.maturityDate)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              d.isMatured
                                  ? "満期"
                                  : "満期まであと ${d.daysLeft} 日",
                              style: TextStyle(
                                fontSize: 12,
                                color: d.isMatured
                                    ? const Color(0xFF006A4E)
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ===== 内容 =====
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _rowWide(
                              "スーパー定期",
                              "${_yen(d.amount)} 円",
                              isTitle: true,
                            ),
                            _rowWide("預入番号", no),
                            _rowWide("預入期間", "${d.years} 年"),
                            _rowWide(
                              "金利",
                              "${(d.rate * 100).toStringAsFixed(3)}%",
                            ),
                            _rowWide("満期時取扱・利払方式", "満期解約"),
                            _rowWide("課税区分", "分離課税"),
                          ],
                        ),
                      ),

                      const Divider(height: 1),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// ===============================
  /// UI Helper
  /// ===============================
  Widget _rowWide(String left, String right, {bool isTitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: TextStyle(
                fontSize: isTitle ? 14 : 12,
                fontWeight: isTitle ? FontWeight.w600 : null,
                color: isTitle ? Colors.black : Colors.black54,
              ),
            ),
          ),
          Text(
            right,
            style: TextStyle(
              fontSize: isTitle ? 18 : 13,
              fontWeight: isTitle ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime d) =>
      "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}";

  String _yen(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}
