import 'package:flutter/material.dart';
import '../services/database_service.dart';

class DebugDataScreen extends StatelessWidget {
  const DebugDataScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Database Data')),
      body: FutureBuilder(
        future: _getAllData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: [
                Text('Reports: ${snapshot.data}'),
                // Add more data display here
              ],
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Future<String> _getAllData() async {
    final db = await DatabaseService.database;
    final reports = await db.query('reports');
    final expenses = await db.query('expenses');
    final stock = await db.query('stock_items');
    
    return 'Reports: ${reports.length}\nExpenses: ${expenses.length}\nStock: ${stock.length}';
  }
}
