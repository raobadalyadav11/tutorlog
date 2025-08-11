import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../providers/student_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/payment_provider.dart';

import 'students_screen.dart';
import 'attendance_screen.dart';
import 'payments_screen.dart';
import 'reports_screen.dart';
import 'subscription_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TutorLog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.subscriptions),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your students and track attendance',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Consumer(builder: (context, ref, child) {
              final students = ref.watch(studentsProvider);
              final attendance = ref.watch(attendanceProvider);
              final payments = ref.watch(paymentsProvider);
              
              // Load data when dashboard builds
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(studentsProvider.notifier).loadStudents();
                ref.read(attendanceProvider.notifier).loadAttendance();
                ref.read(paymentsProvider.notifier).loadPayments();
              });
              
              final todayAttendance = attendance.where((a) => 
                a.date.year == DateTime.now().year &&
                a.date.month == DateTime.now().month &&
                a.date.day == DateTime.now().day
              ).toList();
              
              final presentToday = todayAttendance.where((a) => a.isPresent).length;
              final totalCollected = payments.where((p) => p.status == 'Paid').fold(0.0, (sum, p) => sum + p.amount);
              final totalPending = payments.where((p) => p.status == 'Pending').fold(0.0, (sum, p) => sum + p.amount);
              
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Total Students',
                          value: '${students.length}',
                          icon: Icons.people,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: 'Present Today',
                          value: '$presentToday',
                          icon: Icons.check_circle,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Pending Fees',
                          value: '₹${totalPending.toInt()}',
                          icon: Icons.payment,
                          color: AppTheme.warningColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: 'Collected',
                          value: '₹${totalCollected.toInt()}',
                          icon: Icons.trending_up,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    context,
                    'Students',
                    Icons.people,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentsScreen())),
                  ),
                  _buildActionCard(
                    context,
                    'Attendance',
                    Icons.check_circle_outline,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
                  ),
                  _buildActionCard(
                    context,
                    'Payments',
                    Icons.payment,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen())),
                  ),
                  _buildActionCard(
                    context,
                    'Reports',
                    Icons.analytics,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}