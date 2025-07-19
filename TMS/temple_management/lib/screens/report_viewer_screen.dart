import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class ReportViewerScreen extends StatefulWidget {
  const ReportViewerScreen({super.key});

  @override
  State<ReportViewerScreen> createState() => _ReportViewerScreenState();
}

class _ReportViewerScreenState extends State<ReportViewerScreen> {
  String viewType = 'date';
  DateTime? startDate;
  DateTime? endDate;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  bool showReport = false;
  List<Map<String, dynamic>> reportData = [];
  List<Map<String, dynamic>> expenseData = [];
  double grandTotal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Viewer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildViewTypeSelector(),
            const SizedBox(height: 20),
            if (viewType == 'date') _buildDateRangeView(),
            if (viewType == 'month') _buildMonthView(),
            const SizedBox(height: 20),
            if (showReport) _buildReportDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTypeSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select View Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'date',
                  label: Text('Date Range'),
                  icon: Icon(Icons.date_range),
                ),
                ButtonSegment(
                  value: 'month',
                  label: Text('Monthly'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: {viewType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  viewType = newSelection.first;
                  showReport = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeView() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range Selection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _selectStartDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          startDate != null
                              ? DateFormat('dd/MM/yyyy').format(startDate!)
                              : 'Select Start Date',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Date'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _selectEndDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          endDate != null
                              ? DateFormat('dd/MM/yyyy').format(endDate!)
                              : 'Select End Date',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (startDate != null && endDate != null) ? _fetchReportByDateRange : null,
                child: const Text('Fetch Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Report Selection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(DateFormat.MMMM().format(DateTime(2024, index + 1))),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(10, (index) {
                      int year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fetchReportByMonth,
                child: const Text('Fetch Monthly Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDisplay() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Report Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMainReportTable(),
            const SizedBox(height: 20),
            _buildExpenseTable(),
            const SizedBox(height: 20),
            _buildGrandTotal(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainReportTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Summary',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Opening Balance')),
              DataColumn(label: Text('UPI Total')),
              DataColumn(label: Text('Expense Total')),
              DataColumn(label: Text('Grand Total')),
              DataColumn(label: Text('Cash Total')),
            ],
            rows: reportData.map((data) {
              return DataRow(cells: [
                DataCell(Text(data['date'] ?? '')),
                DataCell(Text('₹${data['opening_balance'] ?? 0}')),
                DataCell(Text('₹${data['upi_total'] ?? 0}')),
                DataCell(Text('₹${data['expense_total'] ?? 0}')),
                DataCell(Text('₹${data['grand_total'] ?? 0}')),
                DataCell(Text('₹${data['cash_total'] ?? 0}')),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Expense Name')),
            DataColumn(label: Text('Amount')),
          ],
          rows: expenseData.map((expense) {
            return DataRow(cells: [
              DataCell(Text(expense['date'] ?? '')),
              DataCell(Text(expense['name'] ?? '')),
              DataCell(Text('₹${expense['amount'] ?? 0}')),
            ]);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGrandTotal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Grand Total:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '₹${grandTotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        showReport = false;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        showReport = false;
      });
    }
  }

  void _fetchReportByDateRange() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    setState(() {
      reportData.clear();
      expenseData.clear();
      grandTotal = 0;
      showReport = false;
    });

    try {
      final reports = await DatabaseService.getReportsByDateRange(startDate!, endDate!);
      final expenses = await DatabaseService.getExpensesByDateRange(startDate!, endDate!);

      if (reports.isEmpty && expenses.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data found for selected date range')),
          );
        }
        return;
      }

      setState(() {
        reportData = reports.map((report) => {
          'date': DateFormat('dd/MM/yyyy').format(DateTime.parse(report.date)),
          'opening_balance': report.openingBalance,
          'upi_total': report.upiTotal,
          'expense_total': report.expenseTotal,
          'grand_total': report.grandTotal,
          'cash_total': report.cashTotal,
        }).toList();

        expenseData = expenses.map((expense) => {
          'date': DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date)),
          'name': expense.name,
          'amount': expense.amount,
        }).toList();

        grandTotal = reports.fold(0.0, (sum, report) => sum + report.grandTotal);
        showReport = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching reports: $e')),
        );
      }
    }
  }

  void _fetchReportByMonth() async {
    setState(() {
      reportData.clear();
      expenseData.clear();
      grandTotal = 0;
      showReport = false;
    });

    try {
      // Calculate month start and end dates
      final startOfMonth = DateTime(selectedYear, selectedMonth, 1);
      final endOfMonth = DateTime(selectedYear, selectedMonth + 1, 0);

      // Fetch actual data from database
      final reports = await DatabaseService.getReportsByDateRange(startOfMonth, endOfMonth);
      final expenses = await DatabaseService.getExpensesByDateRange(startOfMonth, endOfMonth);

      if (reports.isEmpty && expenses.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No data found for ${DateFormat.MMMM().format(DateTime(selectedYear, selectedMonth))} $selectedYear')),
          );
        }
        return;
      }

      setState(() {
        reportData = reports.map((report) => {
          'date': DateFormat('dd/MM/yyyy').format(DateTime.parse(report.date)),
          'opening_balance': report.openingBalance,
          'upi_total': report.upiTotal,
          'expense_total': report.expenseTotal,
          'grand_total': report.grandTotal,
          'cash_total': report.cashTotal,
        }).toList();

        expenseData = expenses.map((expense) => {
          'date': DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date)),
          'name': expense.name,
          'amount': expense.amount,
        }).toList();

        grandTotal = reports.fold(0.0, (sum, report) => sum + report.grandTotal);
        showReport = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching monthly reports: $e')),
        );
      }
    }
  }

  // Removed _downloadPDF method
}































