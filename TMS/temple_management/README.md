# 🏛️ Temple Management System (TMS)

A comprehensive Flutter application for managing temple operations, finances, and inventory with offline capabilities.

## 📱 About This App

The Temple Management System is designed to help temples manage their daily operations including:
- Financial reporting and tracking
- Expense management
- Stock/inventory updates
- Historical data viewing
- Date-wise report generation

## ✨ Features

- 📊 **Report Generator** - Create detailed financial reports
- 👁️ **Report Viewer** - View and download saved reports
- 📅 **Date-wise Reports** - Generate reports for specific dates
- 📦 **Stock Management** - Update and track inventory
- 📜 **History Tracking** - View all past transactions
- 💾 **Offline Storage** - Works without internet connection
- 📱 **Cross-platform** - Runs on Android, iOS, and Web

## 🛠️ Technology Stack

- **Framework:** Flutter (Dart)
- **Database:** SQLite (Local storage)
- **Platforms:** Android, iOS, Web, Windows, macOS, Linux
- **Storage:** Device internal storage (No cloud dependency)

## 📋 Prerequisites

Before running this project, make sure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Latest stable version)
- [Dart SDK](https://dart.dev/get-dart) (Comes with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/temple-management-system.git
cd temple-management-system
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the Application
```bash
# For mobile (Android/iOS)
flutter run

# For web
flutter run -d chrome

# For desktop
flutter run -d windows  # or macos/linux
```

## 📱 How to Use

### First Time Setup
1. Launch the app
2. Navigate through the home screen
3. Start by updating stock information
4. Begin creating daily reports

### Daily Operations
1. **Morning:** Update opening balance
2. **Throughout day:** Record expenses and income
3. **Evening:** Generate daily report
4. **Review:** Check history and previous reports

### Report Generation
1. Go to "Report Generator"
2. Enter daily financial data
3. Save the report
4. View in "Report Viewer"

## 🗄️ Database Information

- **Type:** SQLite (Local database)
- **Location:** Device internal storage
- **File:** `temple_management.db`
- **Tables:** Reports, Expenses, Stock
- **Backup:** Manual export/import (future feature)

## 📊 Data Storage

### What's Stored:
- Daily financial reports
- Expense records
- Stock/inventory data
- Transaction history

### Storage Location:
- **Mobile:** Device internal storage
- **Web:** Browser local storage
- **Desktop:** Application data folder

### Data Usage:
- ✅ **No internet required** for core functions
- ✅ **No mobile data consumption** for storage
- ✅ **Fast offline access**

## 🔧 Development

### Project Structure
```
lib/
├── main.dart              # App entry point
├── screens/               # All app screens
│   ├── home_screen.dart
│   ├── calculator_screen.dart
│   ├── report_generator_screen.dart
│   └── ...
├── services/              # Business logic
│   └── database_service.dart
├── models/                # Data models
└── widgets/               # Reusable components
```

### Adding New Features
1. Create new screen in `lib/screens/`
2. Add navigation in appropriate screen
3. Update database service if needed
4. Test on multiple platforms

## 🐛 Troubleshooting

### Common Issues:

**App won't start:**
```bash
flutter clean
flutter pub get
flutter run
```

**Database errors:**
- Delete app and reinstall
- Check device storage space

**Build errors:**
```bash
flutter doctor
flutter upgrade
```

## 📈 Future Enhancements

- [ ] Cloud backup and sync
- [ ] Multi-temple support
- [ ] Advanced reporting with charts
- [ ] Export to PDF/Excel
- [ ] User authentication
- [ ] Donation tracking
- [ ] Event management

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an [Issue](https://github.com/yourusername/temple-management-system/issues)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- SQLite for reliable local storage
- Temple community for requirements and feedback

---

**Made with ❤️ for Temple Management**

### 📱 Screenshots

[Add screenshots of your app here]

### 🎯 Quick Start Video

[Add a demo video link here]
