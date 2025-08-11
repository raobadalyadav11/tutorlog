import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/payment.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import 'auth_provider.dart';

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, List<Payment>>((ref) {
  return PaymentsNotifier(ref);
});

class PaymentsNotifier extends StateNotifier<List<Payment>> {
  final Ref ref;
  final _uuid = const Uuid();

  PaymentsNotifier(this.ref) : super([]);

  Future<void> loadPayments({DateTime? startDate, DateTime? endDate}) async {
    final tutor = ref.read(currentTutorProvider);
    if (tutor == null) return;

    // Load from local storage first
    final localPayments = LocalStorageService.getPayments(
      tutor.id,
      startDate: startDate,
      endDate: endDate,
    );
    state = localPayments;

    // Try to sync from Firebase if connected
    if (await SyncService.isConnected()) {
      try {
        final firebasePayments = await FirebaseService.getPayments(
          tutor.id,
          startDate: startDate,
          endDate: endDate,
        );
        for (final payment in firebasePayments) {
          await LocalStorageService.savePayment(payment);
        }
        state = LocalStorageService.getPayments(
          tutor.id,
          startDate: startDate,
          endDate: endDate,
        );
      } catch (e) {
        // Continue with local data if Firebase fails
      }
    }
  }

  Future<void> addPayment({
    required String studentId,
    required double amount,
    required DateTime date,
    required String mode,
    required String status,
    String? note,
    String? transactionId,
  }) async {
    final tutor = ref.read(currentTutorProvider);
    if (tutor == null) return;

    final payment = Payment(
      id: _uuid.v4(),
      studentId: studentId,
      tutorId: tutor.id,
      amount: amount,
      date: date,
      mode: mode,
      status: status,
      note: note,
      createdAt: DateTime.now(),
      transactionId: transactionId,
    );

    // Save locally first
    await LocalStorageService.savePayment(payment);
    state = [...state, payment];

    // Try to sync to Firebase
    if (await SyncService.isConnected()) {
      try {
        await FirebaseService.createPayment(payment);
        await LocalStorageService.markPaymentSynced(payment.id);
      } catch (e) {
        // Will be synced later
      }
    }
  }

  Future<void> updatePayment(Payment updatedPayment) async {
    // Update locally
    await LocalStorageService.savePayment(updatedPayment);
    state = state.map((p) => p.id == updatedPayment.id ? updatedPayment : p).toList();

    // Try to sync to Firebase
    if (await SyncService.isConnected()) {
      try {
        await FirebaseService.updatePayment(updatedPayment);
      } catch (e) {
        // Will be synced later
      }
    }
  }

  List<Payment> getPaymentsForStudent(String studentId) {
    return state.where((p) => p.studentId == studentId).toList();
  }

  double getTotalCollected() {
    return state.where((p) => p.status == 'Paid').fold(0.0, (sum, p) => sum + p.amount);
  }

  double getTotalPending() {
    return state.where((p) => p.status == 'Pending').fold(0.0, (sum, p) => sum + p.amount);
  }
}