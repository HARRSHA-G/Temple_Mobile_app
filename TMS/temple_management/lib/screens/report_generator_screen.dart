import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/report_data.dart';
import '../models/expense_data.dart';

class ReportGeneratorScreen extends StatefulWidget {
  const ReportGeneratorScreen({super.key});

  @override
  State<ReportGeneratorScreen> createState() => _ReportGeneratorScreenState();
}

class _ReportGeneratorScreenState extends State<ReportGeneratorScreen> {
  DateTime? selectedDate;
  String reportType = 'ob';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _upiAmountController = TextEditingController();
  final TextEditingController _donationAmountController = TextEditingController();
  final TextEditingController _materialAmountController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  final TextEditingController _fromReceiptController = TextEditingController();
  final TextEditingController _toReceiptController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();
  final TextEditingController _receiptNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Map<String, List<Map<String, dynamic>>> reportData = {
    'ob': [],
    'gc': [],
    'ml': [],
    'irumudi': [],
    'donation': [],
    'material': [],
    'upi': [],
    'expense': [],
  };

  final Map<String, String> reportTypes = {
    'ob': 'Opening Balance',
    'gc': 'Ghee/Coconut',
    'ml': 'Maaladharane',
    'irumudi': 'Irumudi',
    'donation': 'Donation',
    'material': 'Material',
    'upi': 'UPI',
    'expense': 'Expense',
  };

  @override
  void initState() {
    super.initState();
    _fromReceiptController.addListener(_calculateAndFillTotal);
    _toReceiptController.addListener(_calculateAndFillTotal);
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await DatabaseService.database;
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiAmountController.dispose();
    _donationAmountController.dispose();
    _materialAmountController.dispose();
    _expenseAmountController.dispose();
    _fromReceiptController.dispose();
    _toReceiptController.dispose();
    _totalCostController.dispose();
    _receiptNumberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Generator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDateAndTypeSelector(),
            const SizedBox(height: 20),
            _buildFormSection(),
            const SizedBox(height: 20),
            _buildPreviewSection(),
            const SizedBox(height: 20),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndTypeSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Report Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Date:'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : 'Select Date',
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
                      const Text('Report Type:'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: reportType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: reportTypes.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            reportType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add ${reportTypes[reportType]} Entry',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFormFields(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addEntry,
                icon: const Icon(Icons.add),
                label: const Text('Add Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    switch (reportType) {
      case 'ob':
        return _buildOpeningBalanceForm();
      case 'gc':
      case 'ml':
        return _buildReceiptForm();
      case 'irumudi':
      case 'donation':
        return _buildReceiptNumberForm();
      case 'material':
      case 'expense':
        return _buildMaterialExpenseForm();
      case 'upi':
        return _buildUPIForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOpeningBalanceForm() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Opening Balance Amount',
        border: OutlineInputBorder(),
        prefixText: '₹ ',
      ),
      keyboardType: TextInputType.number,
      onFieldSubmitted: (value) => _addEntry(),
    );
  }

  Widget _buildReceiptForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fromReceiptController,
                decoration: const InputDecoration(
                  labelText: 'From Receipt',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _toReceiptController,
                decoration: const InputDecoration(
                  labelText: 'To Receipt',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _totalCostController,
          decoration: const InputDecoration(
            labelText: 'Total Cost',
            border: OutlineInputBorder(),
            prefixText: '₹ ',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildReceiptNumberForm() {
    TextEditingController amountController = reportType == 'donation'
        ? _donationAmountController
        : _amountController;

    return Column(
      children: [
        TextFormField(
          controller: _receiptNumberController,
          decoration: InputDecoration(
            labelText: '${reportTypes[reportType]} Receipt Number',
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
            prefixText: '₹ ',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildMaterialExpenseForm() {
    TextEditingController amountController = reportType == 'material'
        ? _materialAmountController
        : _expenseAmountController;

    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: '${reportTypes[reportType]} Name',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
            prefixText: '₹ ',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildUPIForm() {
    return TextFormField(
      controller: _upiAmountController,
      decoration: const InputDecoration(
        labelText: 'UPI Amount',
        border: OutlineInputBorder(),
        prefixText: '₹ ',
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildPreviewTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTable() {
    List<Widget> allTables = [];

    for (String type in reportTypes.keys) {
      final data = reportData[type] ?? [];
      if (data.isNotEmpty) {
        allTables.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  reportTypes[type]!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: _getTableColumnsForType(type),
                  rows: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> item = entry.value;
                    return DataRow(
                      cells: _getTableCellsForType(type, index + 1, item),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    }

    if (allTables.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Text(
            'No entries added yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(children: allTables);
  }

  List<DataColumn> _getTableColumnsForType(String type) {
    switch (type) {
      case 'ob':
        return const [
          DataColumn(label: Text('S.No')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Action')),
        ];
      case 'gc':
      case 'ml':
        return const [
          DataColumn(label: Text('S.No')),
          DataColumn(label: Text('Receipt Range')),
          DataColumn(label: Text('Count')),
          DataColumn(label: Text('Total Cost')),
          DataColumn(label: Text('Action')),
        ];
      case 'irumudi':
      case 'donation':
        return const [
          DataColumn(label: Text('S.No')),
          DataColumn(label: Text('Receipt Number')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Action')),
        ];
      case 'material':
      case 'expense':
        return const [
          DataColumn(label: Text('S.No')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Action')),
        ];
      case 'upi':
        return const [
          DataColumn(label: Text('S.No')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Action')),
        ];
      default:
        return [];
    }
  }

  List<DataCell> _getTableCellsForType(String type, int sNo, Map<String, dynamic> item) {
    List<DataCell> cells = [DataCell(Text(sNo.toString()))];

    switch (type) {
      case 'ob':
      case 'upi':
        cells.add(DataCell(Text('₹${item['amount'] ?? 0}')));
        break;
      case 'gc':
      case 'ml':
        cells.addAll([
          DataCell(Text('${item['from']}-${item['to']}')),
          DataCell(Text('${item['count'] ?? 0}')),
          DataCell(Text('₹${item['total'] ?? 0}')),
        ]);
        break;
      case 'irumudi':
      case 'donation':
        cells.addAll([
          DataCell(Text('${item['receipt'] ?? ''}')),
          DataCell(Text('₹${item['amount'] ?? 0}')),
        ]);
        break;
      case 'material':
      case 'expense':
        cells.addAll([
          DataCell(Text('${item['name'] ?? ''}')),
          DataCell(Text('₹${item['amount'] ?? 0}')),
        ]);
        break;
    }

    cells.add(
      DataCell(
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeEntryFromType(type, sNo - 1),
        ),
      ),
    );

    return cells;
  }

  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: selectedDate != null && _hasReportData() ? _saveToDatabase : null,
      icon: const Icon(Icons.save),
      label: const Text('Save to Database'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }

  bool _hasReportData() {
    return reportData.values.any((list) => list.isNotEmpty);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addEntry() {
    Map<String, dynamic> entry = {};

    switch (reportType) {
      case 'ob':
        if (_amountController.text.isEmpty) return;
        entry = {'amount': double.tryParse(_amountController.text) ?? 0};
        break;
      case 'gc':
      case 'ml':
        if (_fromReceiptController.text.isEmpty ||
            _toReceiptController.text.isEmpty ||
            _totalCostController.text.isEmpty) {
          return;
        }
        int from = int.tryParse(_fromReceiptController.text) ?? 0;
        int to = int.tryParse(_toReceiptController.text) ?? 0;
        entry = {
          'from': from,
          'to': to,
          'count': to - from + 1,
          'total': double.tryParse(_totalCostController.text) ?? 0,
        };
        break;
      case 'irumudi':
        if (_receiptNumberController.text.isEmpty || _amountController.text.isEmpty) return;
        entry = {
          'receipt': _receiptNumberController.text,
          'amount': double.tryParse(_amountController.text) ?? 0,
        };
        break;
      case 'donation':
        if (_receiptNumberController.text.isEmpty || _donationAmountController.text.isEmpty) return;
        entry = {
          'receipt': _receiptNumberController.text,
          'amount': double.tryParse(_donationAmountController.text) ?? 0,
        };
        break;
      case 'material':
        if (_nameController.text.isEmpty || _materialAmountController.text.isEmpty) return;
        entry = {
          'name': _nameController.text,
          'amount': double.tryParse(_materialAmountController.text) ?? 0,
        };
        break;
      case 'expense':
        if (_nameController.text.isEmpty || _expenseAmountController.text.isEmpty) return;
        entry = {
          'name': _nameController.text,
          'amount': double.tryParse(_expenseAmountController.text) ?? 0,
        };
        break;
      case 'upi':
        if (_upiAmountController.text.isEmpty) return;
        entry = {'amount': double.tryParse(_upiAmountController.text) ?? 0};
        break;
    }

    setState(() {
      reportData[reportType]!.add(entry);
    });

    _clearAllFields();
  }

  void _clearAllFields() {
    _amountController.clear();
    _upiAmountController.clear();
    _donationAmountController.clear();
    _materialAmountController.clear();
    _expenseAmountController.clear();
    _fromReceiptController.clear();
    _toReceiptController.clear();
    _totalCostController.clear();
    _receiptNumberController.clear();
    _nameController.clear();
  }

  void _removeEntryFromType(String type, int index) {
    setState(() {
      reportData[type]!.removeAt(index);
    });
  }

  void _calculateAndFillTotal() {
    if (_fromReceiptController.text.isNotEmpty && _toReceiptController.text.isNotEmpty) {
      int from = int.tryParse(_fromReceiptController.text) ?? 0;
      int to = int.tryParse(_toReceiptController.text) ?? 0;

      if (to >= from) {
        int count = (to - from) + 1;
        double pricePerReceipt = reportType == 'gc' ? 130.0 : 15.0;
        double total = count * pricePerReceipt;
        _totalCostController.text = total.toString();
      }
    }
  }

  Future<void> _saveToDatabase() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    if (!_hasReportData()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No report data to save')),
      );
      return;
    }

    try {
      // Add detailed logging for database initialization
      debugPrint('Initializing database...');
      final db = await DatabaseService.database;
      debugPrint('Database initialized successfully: $db');

      double grandTotal = 0;
      double upiTotal = 0;
      double expenseTotal = 0;
      double openingBalance = 0;

      // Calculate totals with logging
      debugPrint('Calculating totals...');
      for (var entry in reportData['ob'] ?? []) {
        openingBalance += (entry['amount'] ?? 0).toDouble();
      }
      debugPrint('Opening balance: $openingBalance');

      for (String type in ['gc', 'ml', 'irumudi', 'donation', 'material']) {
        for (var entry in reportData[type] ?? []) {
          grandTotal += (entry['amount'] ?? entry['total'] ?? 0).toDouble();
        }
      }
      debugPrint('Grand total: $grandTotal');

      for (var entry in reportData['upi'] ?? []) {
        upiTotal += (entry['amount'] ?? 0).toDouble();
      }
      debugPrint('UPI total: $upiTotal');

      for (var entry in reportData['expense'] ?? []) {
        expenseTotal += (entry['amount'] ?? 0).toDouble();
      }
      debugPrint('Expense total: $expenseTotal');

      double cashTotal = grandTotal + openingBalance - (upiTotal + expenseTotal);
      debugPrint('Cash total: $cashTotal');

      // Create report object
      debugPrint('Creating report object...');
      final reportDataObj = ReportData(
        date: selectedDate!.toIso8601String(),
        openingBalance: openingBalance,
        upiTotal: upiTotal,
        expenseTotal: expenseTotal,
        grandTotal: grandTotal,
        cashTotal: cashTotal,
      );
      
      debugPrint('Inserting report to database...');
      await DatabaseService.insertReport(reportDataObj);
      debugPrint('Report inserted successfully');

      // Insert expenses
      debugPrint('Inserting expenses...');
      for (var entry in reportData['expense'] ?? []) {
        final expenseData = ExpenseData(
          date: selectedDate!.toIso8601String(),
          name: entry['name'] ?? '',
          amount: (entry['amount'] ?? 0).toDouble(),
        );
        await DatabaseService.insertExpense(expenseData);
      }
      debugPrint('Expenses inserted successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved successfully! Grand Total: ₹${grandTotal.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        reportData = {
          'ob': [],
          'gc': [],
          'ml': [],
          'irumudi': [],
          'donation': [],
          'material': [],
          'upi': [],
          'expense': [],
        };
        selectedDate = null;
      });
    } catch (e) {
      debugPrint('Detailed error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      if (e.toString().contains('database')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Database error: Please restart the app and try again'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

}









