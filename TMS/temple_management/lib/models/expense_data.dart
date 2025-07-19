class ExpenseData {
  final String date;
  final String name;
  final double amount;

  ExpenseData({
    required this.date,
    required this.name,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'name': name,
      'amount': amount,
    };
  }

  factory ExpenseData.fromMap(Map<String, dynamic> map) {
    return ExpenseData(
      date: map['date'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }
}