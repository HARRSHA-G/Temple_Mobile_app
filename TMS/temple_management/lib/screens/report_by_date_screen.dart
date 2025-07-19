import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/report_data.dart';
import '../models/expense_data.dart';

class ReportByDateScreen extends StatefulWidget {
  const ReportByDateScreen({super.key});
  @override
  ReportByDateScreenState createState() => ReportByDateScreenState();
}

class ReportByDateScreenState extends State<ReportByDateScreen>
    with TickerProviderStateMixin {
  DateTime? selectedDate;
  List<ReportData> reports = [];
  List<ExpenseData> expenses = [];
  bool isLoading = false;
  bool showReport = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _reportController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _reportAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _reportController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _reportAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _reportController, curve: Curves.easeInOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text('View Report By Date'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _slideController]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: const Text(
                              'View Report By Date',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      _buildAnimatedDateSelector(),
                      const SizedBox(height: 20),
                      if (showReport) ...[
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _reportController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _reportAnimation,
                                child: Transform.scale(
                                  scale: _reportAnimation.value,
                                  child: _buildReportContent(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedDateSelector() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    'Select Date:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6),
                          color: selectedDate != null
                              ? Colors.green.shade50
                              : Colors.white,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            selectedDate != null
                                ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                                : 'Select Date',
                            key: ValueKey(selectedDate),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _generateReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: isLoading ? 0 : 4,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Generate Report'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Preview for ${DateFormat('dd-MM-yyyy').format(selectedDate!)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildReportTable(),
          SizedBox(height: 20),
          _buildExpenseTable(),
          SizedBox(height: 20),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildReportTable() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Daily Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    child: Table(
                      border: TableBorder.all(color: Colors.grey[300]!),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF10DFFF),
                                Colors.cyan.shade300,
                              ],
                            ),
                          ),
                          children: [
                            _buildTableCell('Opening Balance', isHeader: true),
                            _buildTableCell('UPI Total', isHeader: true),
                            _buildTableCell('Expense Total', isHeader: true),
                            _buildTableCell('Grand Total', isHeader: true),
                            _buildTableCell('Cash Total', isHeader: true),
                          ],
                        ),
                        if (reports.isNotEmpty)
                          TableRow(
                            children: [
                              _buildAnimatedTableCell(
                                'Rs. ${reports.first.openingBalance.toStringAsFixed(2)}',
                                0,
                              ),
                              _buildAnimatedTableCell(
                                'Rs. ${reports.first.upiTotal.toStringAsFixed(2)}',
                                100,
                              ),
                              _buildAnimatedTableCell(
                                'Rs. ${reports.first.expenseTotal.toStringAsFixed(2)}',
                                200,
                              ),
                              _buildAnimatedTableCell(
                                'Rs. ${reports.first.grandTotal.toStringAsFixed(2)}',
                                300,
                              ),
                              _buildAnimatedTableCell(
                                'Rs. ${reports.first.cashTotal.toStringAsFixed(2)}',
                                400,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTableCell(String text, int delay) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Expense Report',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Table(
            border: TableBorder.all(color: Colors.grey[300]!),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Color(0xFF10DFFF)),
                children: [
                  _buildTableCell('Sl No', isHeader: true),
                  _buildTableCell('Expense Name', isHeader: true),
                  _buildTableCell('Amount', isHeader: true),
                ],
              ),
              ...expenses.asMap().entries.map((entry) {
                int index = entry.key;
                ExpenseData expense = entry.value;
                return TableRow(
                  children: [
                    _buildTableCell('${index + 1}'),
                    _buildTableCell(expense.name),
                    _buildTableCell('Rs. ${expense.amount.toStringAsFixed(2)}'),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    if (reports.isEmpty) return SizedBox();

    final report = reports.first;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Opening Balance:',
            'Rs. ${report.openingBalance.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'UPI Total:',
            'Rs. ${report.upiTotal.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Expense Total:',
            'Rs. ${report.expenseTotal.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Grand Total:',
            'Rs. ${report.grandTotal.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Cash Total:',
            'Rs. ${report.cashTotal.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.black87,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Remove this line: showReport = false;
      });
    }
  }

  Future<void> _generateReport() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    setState(() {
      isLoading = true;
      showReport = false;
    });

    try {
      final startOfDay = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      );
      final endOfDay = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        23,
        59,
        59,
      );

      final reportList = await DatabaseService.getReportsByDateRange(
        startOfDay,
        endOfDay,
      );
      final expenseList = await DatabaseService.getExpensesByDateRange(
        startOfDay,
        endOfDay,
      );

      setState(() {
        reports = reportList;
        expenses = expenseList;
        showReport = true;
        isLoading = false;
      });

      // Start report animation
      _reportController.reset();
      _reportController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching report: $e')));
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _reportController.dispose();
    super.dispose();
  }
}
