class CalculationService {
  static double calculateGrandTotal({
    required double gcTotal,
    required double mlTotal,
    required double irumudiTotal,
    required double donationTotal,
    required double materialTotal,
  }) {
    return gcTotal + mlTotal + irumudiTotal + donationTotal + materialTotal;
  }

  static double calculateCashTotal({
    required double grandTotal,
    required double openingBalance,
    required double upiTotal,
    required double expenseTotal,
  }) {
    return grandTotal + openingBalance - (upiTotal + expenseTotal);
  }
}