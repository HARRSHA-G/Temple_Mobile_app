import 'package:flutter/material.dart';
import '../screens/report_generator_screen.dart';
import '../screens/report_viewer_screen.dart';
import '../screens/report_by_date_screen.dart';
import '../screens/stock_update_screen.dart';
import '../screens/history_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final drawerWidth = constraints.maxWidth < 600 
            ? constraints.maxWidth * 0.85 
            : 300;
        
        return Drawer(
          width: drawerWidth.toDouble(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFFF2803E)),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Temple Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.assessment,
                title: 'Report Generator',
                subtitle: 'Generate daily reports',
                onTap: () => _navigateToScreen(context, const ReportGeneratorScreen()),
                isSmallScreen: isSmallScreen,
              ),
              _buildDrawerItem(
                context,
                icon: Icons.visibility,
                title: 'Report Viewer',
                subtitle: 'View and download reports',
                onTap: () => _navigateToScreen(context, const ReportViewerScreen()),
                isSmallScreen: isSmallScreen,
              ),
              _buildDrawerItem(
                context,
                icon: Icons.date_range,
                title: 'Report by Date',
                subtitle: 'View reports by specific date',
                onTap: () => _navigateToScreen(context, ReportByDateScreen()),
                isSmallScreen: isSmallScreen,
              ),
              _buildDrawerItem(
                context,
                icon: Icons.inventory,
                title: 'Stock Update',
                subtitle: 'Update stock information',
                onTap: () => _navigateToScreen(context, const StockUpdateScreen()),
                isSmallScreen: isSmallScreen,
              ),
              _buildDrawerItem(
                context,
                icon: Icons.history,
                title: 'History',
                subtitle: 'View transaction history',
                onTap: () => _navigateToScreen(context, const HistoryScreen()),
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 4 : 8,
      ),
      leading: Icon(
        icon,
        color: Color(0xFFF2803E),
        size: isSmallScreen ? 20 : 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isSmallScreen ? 10 : 12,
          color: Colors.grey[600],
        ),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}





