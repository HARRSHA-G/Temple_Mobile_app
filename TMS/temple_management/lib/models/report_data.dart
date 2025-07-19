class ReportData {
  final String date;
  final double openingBalance;
  final double upiTotal;
  final double expenseTotal;
  final double grandTotal;
  final double cashTotal;

  ReportData({
    required this.date,
    required this.openingBalance,
    required this.upiTotal,
    required this.expenseTotal,
    required this.grandTotal,
    required this.cashTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'opening_balance': openingBalance,
      'upi_total': upiTotal,
      'expense_total': expenseTotal,
      'grand_total': grandTotal,
      'cash_total': cashTotal,
    };
  }

  factory ReportData.fromMap(Map<String, dynamic> map) {
    return ReportData(
      date: map['date'] ?? '',
      openingBalance: (map['opening_balance'] ?? 0).toDouble(),
      upiTotal: (map['upi_total'] ?? 0).toDouble(),
      expenseTotal: (map['expense_total'] ?? 0).toDouble(),
      grandTotal: (map['grand_total'] ?? 0).toDouble(),
      cashTotal: (map['cash_total'] ?? 0).toDouble(),
    );
  }
}