import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calculator_screen.dart';
import 'report_by_date_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sri Kaliyuga Varada Ayyappaswamy Temple'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(context, 'Stock Update', Icons.inventory, null),
            _buildMenuCard(context, 'Book Irumudi', Icons.book, null),
            _buildMenuCard(context, 'Materials', Icons.list, null),
            _buildMenuCard(context, 'Maaladharane', Icons.beenhere, null),
            _buildMenuCard(context, 'Ghee / Coconut', Icons.local_grocery_store, null),
            _buildMenuCard(context, 'Irumudi / Pay Due', Icons.payment, null),
            _buildMenuCard(context, 'Scheduled Irumudi', Icons.schedule, null),
            _buildMenuCard(context, 'Expense', Icons.money_off, null),
            _buildMenuCard(context, 'Donation', Icons.volunteer_activism, null),
            _buildMenuCard(context, 'Cash Report', Icons.assessment, null),
            _buildMenuCard(context, 'Calculator', Icons.calculate, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalculatorScreen()),
              );
            }),
            _buildMenuCard(context, 'Reports', Icons.report, null),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportByDateScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Color(0xFFF2803E), Color(0xFFFF9800)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.date_range, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        'Report by Date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, VoidCallback? onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap ?? () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title feature coming soon!')),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

