import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_service.dart';
import 'local_storage_service.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/payment.dart';

class SyncService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  static bool _isSyncing = false;

  static Future<void> initialize() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && !_isSyncing) {
        syncData();
      }
    });
  }

  static Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static Future<void> syncData() async {
    if (_isSyncing || !await isConnected()) return;
    
    _isSyncing = true;
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return;

      // Sync unsynced attendance
      final unsyncedAttendance = LocalStorageService.getUnsyncedAttendance();
      for (final attendance in unsyncedAttendance) {
        try {
          await FirebaseService.createAttendance(attendance);
          await LocalStorageService.markAttendanceSynced(attendance.id);
        } catch (e) {
          // Log error but continue syncing
        }
      }

      // Sync unsynced payments
      final unsyncedPayments = LocalStorageService.getUnsyncedPayments();
      for (final payment in unsyncedPayments) {
        try {
          await FirebaseService.createPayment(payment);
          await LocalStorageService.markPaymentSynced(payment.id);
        } catch (e) {
          // Log error but continue syncing
        }
      }

      // Sync data from Firebase to local
      await _syncFromFirebase(currentUser.uid);
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> _syncFromFirebase(String tutorId) async {
    try {
      // Sync students
      final students = await FirebaseService.getStudents(tutorId);
      for (final student in students) {
        await LocalStorageService.saveStudent(student);
      }

      // Sync attendance (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final attendance = await FirebaseService.getAttendance(
        tutorId,
        startDate: thirtyDaysAgo,
      );
      for (final att in attendance) {
        await LocalStorageService.saveAttendance(att);
      }

      // Sync payments (last 30 days)
      final payments = await FirebaseService.getPayments(
        tutorId,
        startDate: thirtyDaysAgo,
      );
      for (final payment in payments) {
        await LocalStorageService.savePayment(payment);
      }
    } catch (e) {
      // Log error
    }
  }

  static Future<void> forcSync() async {
    await syncData();
  }

  static bool get isSyncing => _isSyncing;

  static void dispose() {
    _connectivitySubscription?.cancel();
  }
}