# TutorLog - Digital Attendance Register

A complete Flutter-based mobile application for tutors to manage student attendance, payments, and generate reports with offline-first architecture and Firebase integration.

## Features

### 🎯 Core Features
- **Student Management**: Add, edit, delete students with batch assignment
- **Attendance Tracking**: Daily attendance marking with date selection
- **Payment Management**: Track fees, payment status, and history
- **Report Generation**: Export attendance and payment reports (PDF/Excel)
- **Offline Support**: Works without internet, syncs when connected
- **Subscription System**: ₹9/month subscription with Razorpay integration

### 🔐 Authentication
- Phone number + OTP verification via Firebase Auth
- Secure user sessions and data isolation

### 📱 User Interface
- Material Design 3 with custom theme
- Responsive layouts for different screen sizes
- Intuitive navigation and user experience

## Tech Stack

### Frontend
- **Flutter 3.0+** - Cross-platform mobile framework
- **Dart** - Programming language
- **Riverpod** - State management
- **Material Design 3** - UI components

### Backend & Services
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Cloud database
- **Firebase Storage** - File storage
- **Firebase Messaging** - Push notifications

### Local Storage
- **Hive** - Local database for offline support
- **Shared Preferences** - App settings

### Integrations
- **Razorpay** - Payment processing
- **PDF Generation** - Report exports
- **Excel Export** - Spreadsheet reports
- **Share Plus** - File sharing

## Project Structure

```
lib/
├── models/           # Data models (Tutor, Student, Attendance, Payment)
├── providers/        # Riverpod state management
├── screens/          # UI screens
│   ├── auth/        # Authentication screens
│   └── ...          # Other screens
├── services/         # Business logic services
├── theme/           # App theming
└── widgets/         # Reusable UI components
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Firebase project setup
- Razorpay account for payments

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd tutorlog
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Add `google-services.json` for Android
- Add `GoogleService-Info.plist` for iOS
- Update `firebase_options.dart` with your config

4. Configure Razorpay
- Update Razorpay key in `subscription_screen.dart`

5. Generate Hive adapters
```bash
flutter packages pub run build_runner build
```

6. Run the app
```bash
flutter run
```

## Architecture

### Offline-First Design
- All data stored locally using Hive
- Automatic sync when internet available
- Graceful handling of network failures

### State Management
- Riverpod for reactive state management
- Separate providers for different domains
- Clean separation of concerns

### Data Flow
1. User actions trigger provider methods
2. Data saved locally first for immediate response
3. Background sync to Firebase when connected
4. UI updates reactively through providers

## Key Components

### Models
- `Tutor` - User profile and subscription info
- `Student` - Student details and batch info
- `Attendance` - Daily attendance records
- `Payment` - Fee payment tracking

### Services
- `FirebaseService` - Firebase operations
- `LocalStorageService` - Hive database operations
- `SyncService` - Offline/online synchronization
- `ExportService` - PDF/Excel report generation

### Providers
- `AuthProvider` - Authentication state
- `StudentProvider` - Student management
- `AttendanceProvider` - Attendance tracking
- `PaymentProvider` - Payment management

## Subscription Model

- **Price**: ₹9/month
- **Payment**: Razorpay integration
- **Features**: Unlimited students, reports, cloud sync
- **Grace Period**: 7 days after expiry

## Export Features

### PDF Reports
- Attendance summary with statistics
- Payment records with totals
- Professional formatting

### Excel Reports
- Detailed attendance data
- Payment transaction history
- Easy to analyze and share

## Security

- Firebase Auth for secure authentication
- User data isolation in Firestore
- Local data encryption with Hive
- Secure payment processing via Razorpay

## Performance

- Lazy loading of data
- Efficient local caching
- Background sync operations
- Optimized UI rendering

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request

## License

This project is licensed under the MIT License.

## Support

For support and queries:
- Email: support@tutorlog.com
- Documentation: [Link to docs]
- Issues: GitHub Issues

---

**TutorLog** - Simplifying attendance management for educators everywhere.