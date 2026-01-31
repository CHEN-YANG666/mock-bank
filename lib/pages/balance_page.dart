import 'package:flutter/material.dart';
import '../bank_state.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ===== AppBar =====
      appBar: AppBar(
        title: const Text("普通預金"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        children: [
          /// ===============================
          /// 残高
          /// ===============================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "現在残高",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  "${_yen(bank.balance)} 円",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          /// ===============================
          /// 操作メニュー
          /// ===============================
          _menuItem(
            title: "入金",
            onTap: () => _showAmountDialog(
              title: "入金",
              onConfirm: _deposit,
            ),
          ),
          const Divider(height: 1),

          _menuItem(
            title: "出金",
            onTap: () => _showAmountDialog(
              title: "出金",
              onConfirm: _withdraw,
            ),
          ),
          const Divider(height: 1),

          /// ⭐ 新增定期入口（正确位置）
          _menuItem(
            title: "定期預金に預け入れる",
            onTap: _showCreateFixedDialog,
          ),

          const Divider(height: 8),

          /// ===============================
          /// 口座信息
          /// ===============================
          _infoSection(),
        ],
      ),
    );
  }

  /// =====================================================
  /// 金额输入 Dialog（✔ 你缺的就是这个）
  /// =====================================================
  void _showAmountDialog({
    required String title,
    required Function(int) onConfirm,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "金額（円）",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("キャンセル"),
          ),
          TextButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount == null || amount <= 0) {
                _alert("正しい金額を入力してください");
                return;
              }
              Navigator.pop(context);
              onConfirm(amount);
            },
            child: const Text("確定"),
          ),
        ],
      ),
    );
  }

  /// =====================================================
  /// 新规定期（从普通预金）
  /// =====================================================
  void _showCreateFixedDialog() {
    final amountController = TextEditingController();
    DateTime startDate = DateTime.now();
    int years = 1;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("定期預金のお申込み"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "預入金額（円）"),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Text("預入日"),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365 * 5)),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) {
                          setStateDialog(() => startDate = d);
                        }
                      },
                      child: Text(_date(startDate)),
                    ),
                  ],
                ),

                Row(
                  children: [
                    const Text("契約期間"),
                    const Spacer(),
                    DropdownButton<int>(
                      value: years,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("1 年")),
                        DropdownMenuItem(value: 2, child: Text("2 年")),
                        DropdownMenuItem(value: 3, child: Text("3 年")),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setStateDialog(() => years = v);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("キャンセル"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006A4E),
                ),
                onPressed: () async {
                  final amount =
                      int.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    _toast("正しい金額を入力してください");
                    return;
                  }
                  if (amount > bank.balance) {
                    _toast("残高が不足しています");
                    return;
                  }

                  setState(() {
                    bank.balance -= amount;

                    bank.deposits.add(
                      FixedDeposit(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        amount: amount,
                        startDate: startDate,
                        years: years,
                        rate: _rateByYears(years),
                      ),
                    );

                    bank.addTransaction(
                      type: TransactionType.fixedOpen,
                      amount: -amount,
                      description: "定期預金 預入",
                    );
                  });

                  await bank.save();
                  Navigator.pop(context);
                },
                child: const Text("預け入れる"),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ===============================
  /// 入金
  /// ===============================
  Future<void> _deposit(int amount) async {
    bank.balance += amount;
    bank.addTransaction(
      type: TransactionType.deposit,
      amount: amount,
      description: "普通預金 入金",
    );
    await bank.save();
    setState(() {});
  }

  /// ===============================
  /// 出金
  /// ===============================
  Future<void> _withdraw(int amount) async {
    if (amount > bank.balance) {
      _alert("残高不足です");
      return;
    }
    bank.balance -= amount;
    bank.addTransaction(
      type: TransactionType.withdraw,
      amount: -amount,
      description: "普通預金 出金",
    );
    await bank.save();
    setState(() {});
  }

  /// ===============================
  /// UI Helper
  /// ===============================
  Widget _menuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _infoSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("口座情報",
              style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          _InfoRow(label: "口座種別", value: "普通預金"),
          _InfoRow(label: "通貨", value: "JPY"),
          _InfoRow(label: "ステータス", value: "利用中"),
        ],
      ),
    );
  }

  double _rateByYears(int y) => 0.00002;

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _alert(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.black54)),
          ),
          Text(value),
        ],
      ),
    );
  }
}
