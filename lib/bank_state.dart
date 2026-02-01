import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final bank = BankState();

enum TransactionType {
  deposit,
  withdraw,
  transfer,
  fixedOpen,
  fixedClose,
}

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
        'type': type.index,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      type: TransactionType.values[json['type']],
      amount: json['amount'],
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }
}

class FixedDeposit {
  final String id;
  final int amount;
  final double rate;
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

  int get daysLeft => maturityDate.difference(DateTime.now()).inDays;
  bool get isMatured => DateTime.now().isAfter(maturityDate);
  int get interest => (amount * rate * years).round();
  int get totalReturn => amount + interest;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'rate': rate,
        'startDate': startDate.toIso8601String(),
        'years': years,
      };

  factory FixedDeposit.fromJson(Map<String, dynamic> json) {
    return FixedDeposit(
      id: json['id'],
      amount: json['amount'],
      rate: json['rate'],
      startDate: DateTime.parse(json['startDate']),
      years: json['years'],
    );
  }
}

class BankState {
  int balance = 9_753_124;
  final List<FixedDeposit> deposits = [];
  final List<BankTransaction> transactions = [];

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

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('balance', balance);
    await sp.setString(
      'deposits',
      jsonEncode(deposits.map((e) => e.toJson()).toList()),
    );
    await sp.setString(
      'transactions',
      jsonEncode(transactions.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    balance = sp.getInt('balance') ?? balance;

    final d = sp.getString('deposits');
    if (d != null) {
      deposits
        ..clear()
        ..addAll(
          (jsonDecode(d) as List)
              .map((e) => FixedDeposit.fromJson(e)),
        );
    }

    final t = sp.getString('transactions');
    if (t != null) {
      transactions
        ..clear()
        ..addAll(
          (jsonDecode(t) as List)
              .map((e) => BankTransaction.fromJson(e)),
        );
    }
  }
}
