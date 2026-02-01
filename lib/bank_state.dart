import 'package:cloud_firestore/cloud_firestore.dart';

/// 全局唯一 BankState（云同步）
final bank = BankState();

/// ===============================
/// 取引类型
/// ===============================
enum TransactionType {
  deposit,      // 入金
  withdraw,     // 出金
  transfer,
  fixedOpen,    // 定期預入
  fixedClose,   // 定期解約
}

/// ===============================
/// 取引记录
/// ===============================
class BankTransaction {
  final TransactionType type;
  final int amount;
  final String description;
  final DateTime date;

  BankTransaction({
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'amount': amount,
        'description': description,
        'date': Timestamp.fromDate(date),
      };

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      amount: json['amount'],
      description: json['description'],
      date: (json['date'] as Timestamp).toDate(),
    );
  }
}

/// ===============================
/// 定期預金
/// ===============================
class FixedDeposit {
  final String id;
  final int amount;
  final double rate; // 年利
  final DateTime startDate;
  final int years;

  FixedDeposit({
    required this.id,
    required this.amount,
    required this.rate,
    required this.startDate,
    required this.years,
  });

  DateTime get maturityDate =>
      DateTime(startDate.year + years, startDate.month, startDate.day);

  int get daysLeft =>
      maturityDate.difference(DateTime.now()).inDays;

  bool get isMatured =>
      DateTime.now().isAfter(maturityDate);

  int get interest =>
      (amount * rate * years).round();

  int get totalReturn =>
      amount + interest;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'rate': rate,
        'startDate': Timestamp.fromDate(startDate),
        'years': years,
      };

  factory FixedDeposit.fromJson(Map<String, dynamic> json) {
    return FixedDeposit(
      id: json['id'],
      amount: json['amount'],
      rate: (json['rate'] as num).toDouble(),
      startDate: (json['startDate'] as Timestamp).toDate(),
      years: json['years'],
    );
  }
}

/// ===============================
/// 银行状态（🔥 Firestore 云同步）
/// ===============================
class BankState {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 👉 简化方案：单用户
  final String _docId = 'default_user';

  int balance = 9_753_124;
  final List<FixedDeposit> deposits = [];
  final List<BankTransaction> transactions = [];

  /// ===============================
  /// 取引追加（本地）
  /// ===============================
  void addTransaction({
    required TransactionType type,
    required int amount,
    required String description,
  }) {
    transactions.insert(
      0,
      BankTransaction(
        type: type,
        amount: amount,
        description: description,
        date: DateTime.now(),
      ),
    );
  }

  /// ===============================
  /// 保存到 Firestore
  /// ===============================
  Future<void> save() async {
    await _db.collection('banks').doc(_docId).set({
      'balance': balance,
      'deposits': deposits.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ===============================
  /// 从 Firestore 读取
  /// ===============================
  Future<void> load() async {
    final doc = await _db
        .collection('banks')
        .doc(_docId)
        .get();

    if (!doc.exists) {
      /// 第一次启动：写入默认数据
      await save();
      return;
    }

    final data = doc.data()!;
    balance = data['balance'] ?? balance;

    deposits
      ..clear()
      ..addAll(
        (data['deposits'] as List)
            .map((e) => FixedDeposit.fromJson(e)),
      );

    transactions
      ..clear()
      ..addAll(
        (data['transactions'] as List)
            .map((e) => BankTransaction.fromJson(e)),
      );
  }
}
