import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import 'auth_provider.dart';

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, List<Attendance>>((ref) {
  return AttendanceNotifier(ref);
});

class AttendanceNotifier extends StateNotifier<List<Attendance>> {
  final Ref ref;
  final _uuid = const Uuid();

  AttendanceNotifier(this.ref) : super([]);

  Future<void> loadAttendance({DateTime? startDate, DateTime? endDate}) async {
    final tutor = ref.read(currentTutorProvider);
    if (tutor == null) return;

    // Load from local storage first
    final localAttendance = LocalStorageService.getAttendance(
      tutor.id,
      startDate: startDate,
      endDate: endDate,
    );
    state = localAttendance;

    // Try to sync from Firebase if connected
    if (await SyncService.isConnected()) {
      try {
        final firebaseAttendance = await FirebaseService.getAttendance(
          tutor.id,
          startDate: startDate,
          endDate: endDate,
        );
        for (final attendance in firebaseAttendance) {
          await LocalStorageService.saveAttendance(attendance);
        }
        state = LocalStorageService.getAttendance(
          tutor.id,
          startDate: startDate,
          endDate: endDate,
        );
      } catch (e) {
        // Continue with local data if Firebase fails
      }
    }
  }

  Future<void> markAttendance({
    required String studentId,
    required DateTime date,
    required bool isPresent,
    String? note,
  }) async {
    final tutor = ref.read(currentTutorProvider);
    if (tutor == null) return;

    final attendance = Attendance(
      id: _uuid.v4(),
      studentId: studentId,
      tutorId: tutor.id,
      date: date,
      isPresent: isPresent,
      note: note,
      createdAt: DateTime.now(),
    );

    // Save locally first
    await LocalStorageService.saveAttendance(attendance);
    state = [...state, attendance];

    // Try to sync to Firebase
    if (await SyncService.isConnected()) {
      try {
        await FirebaseService.createAttendance(attendance);
        await LocalStorageService.markAttendanceSynced(attendance.id);
      } catch (e) {
        // Will be synced later
      }
    }
  }

  Future<void> updateAttendance(Attendance updatedAttendance) async {
    // Update locally
    await LocalStorageService.saveAttendance(updatedAttendance);
    state = state.map((a) => a.id == updatedAttendance.id ? updatedAttendance : a).toList();

    // Try to sync to Firebase
    if (await SyncService.isConnected()) {
      try {
        await FirebaseService.updateAttendance(updatedAttendance);
      } catch (e) {
        // Will be synced later
      }
    }
  }

  List<Attendance> getAttendanceForDate(DateTime date) {
    return state.where((a) => 
      a.date.year == date.year &&
      a.date.month == date.month &&
      a.date.day == date.day
    ).toList();
  }

  List<Attendance> getAttendanceForStudent(String studentId) {
    return state.where((a) => a.studentId == studentId).toList();
  }
}