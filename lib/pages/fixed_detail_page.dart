import 'package:flutter/material.dart';
import '../bank_state.dart';

class FixedDetailPage extends StatelessWidget {
  final FixedDeposit deposit;

  const FixedDetailPage({required this.deposit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("定期預金の詳細"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("${_yen(deposit.amount)} 円"),

            const SizedBox(height: 24),

            _row("本金", "${_yen(deposit.amount)} 円"),
            _row("年利率", "${(deposit.rate * 100).toStringAsFixed(3)}%"),
            _row("預入期間", "${deposit.years} 年"),
            _row("預入日", _date(deposit.startDate)),
            _row("満期日", _date(deposit.maturityDate)),

            const Divider(height: 32),

            _row("利息", "${_yen(deposit.interest)} 円"),
            _row(
              "満期受取額",
              "${_yen(deposit.totalReturn)} 円",
            ),

            const Spacer(),

            /// ===== 満期解約 =====
            if (deposit.isMatured)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006A4E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    bank.balance += deposit.totalReturn;

                    bank.addTransaction(
                      type: TransactionType.fixedClose,
                      amount: deposit.totalReturn,
                      description: "定期預金 満期解約",
                    );

                    bank.deposits.remove(deposit);
                    await bank.save();
                    Navigator.pop(context, true);
                  },
                  child: const Text("解約（満期）"),
                ),
              )

            /// ===== 中途解約 =====
            else
              Column(
                children: [
                  const Text(
                    "※ 中途解約の場合、利息は付きません",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        bank.balance += deposit.amount;

                        bank.addTransaction(
                          type: TransactionType.fixedClose,
                          amount: deposit.amount,
                          description: "定期預金 中途解約",
                        );

                        bank.deposits.remove(deposit);
                        await bank.save();
                        Navigator.pop(context, true);
                      },
                      child: const Text("中途解約"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "満期まであと ${deposit.daysLeft} 日",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _date(DateTime d) {
    return "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}";
  }

  String _yen(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
