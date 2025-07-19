class ReportModel {
  final String date;
  final double openingBalance;
  final double gcTotal;
  final double mlTotal;
  final double irumudiTotal;
  final double donationTotal;
  final double materialTotal;
  final double upiTotal;
  final double expenseTotal;
  
  ReportModel({
    required this.date,
    required this.openingBalance,
    required this.gcTotal,
    required this.mlTotal,
    required this.irumudiTotal,
    required this.donationTotal,
    required this.materialTotal,
    required this.upiTotal,
    required this.expenseTotal,
  });

  // Grand Total = GC + ML + IR + DO + MT
  double get grandTotal => gcTotal + mlTotal + irumudiTotal + donationTotal + materialTotal;
  
  // Cash Total = Grand Total + OB - (UPI + Expense)
  double get cashTotal => grandTotal + openingBalance - (upiTotal + expenseTotal);
}