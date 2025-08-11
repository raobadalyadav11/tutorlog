import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/student.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import 'auth_provider.dart';

final studentsProvider = StateNotifierProvider<StudentsNotifier, List<Student>>((ref) {
  return StudentsNotifier(ref);
});

class StudentsNotifier extends StateNotifier<List<Student>> {
  final Ref ref;
  final _uuid = const Uuid();

  StudentsNotifier(this.ref) : super([]);

  Future<void> loadStudents() async {
    final tutor = ref.read(currentTutorProvider);
    if (tutor != null) {
      // Load from local storage first
      final localStudents = LocalStorageService.getStudents(tutor.id);
      state = localStudents;

      // Try to sync from Firebase if connected
      if (await SyncService.isConnected()) {
        try {
          final firebaseStudents = await FirebaseService.getStudents(tutor.id);
          for (final student in firebaseStudents) {
            await LocalStorageService.saveStudent(student);
          }
          state = LocalStorageService.getStudents(tutor.id);
        } catch (e) {
          // Continue with local data if Firebase fails
        }
      }
    }
  }

  Future<void> addStudent({
    required String name,
    required String batch,
    required double monthlyFee,
    String? phone,
    String? parentName,
  }) async {
    final tutor = ref.read(currentTutorProvider);
    if (tutor == null) return;

    final student = Student(
      id: _uuid.v4(),
      tutorId: tutor.id,
      name: name,
      batch: batch,
      phone: phone,
      parentName: parentName,
      joinDate: DateTime.now(),
      monthlyFee: monthlyFee,
    );

    // Save locally first
    await LocalStorageService.saveStudent(student);
    state = [...state, student];

    // Try to sync to Firebase
    if (await SyncService.isConnected()) {
      try {
        await FirebaseService.createStudent(student);
      } catch (e) {
        // Will be synced later
      }
    }
  }

  Future<void> updateStudent(Student updatedStudent) async {
    // Update locally
    await LocalStorageService.saveStudent(updatedStudent);
    state = state.map((s) => s.id == updatedStudent.id ? updatedStudent : s).toList();

    // Try to sync to Firebase
    if (await SyncService.isConnected()) {
      try {
        await FirebaseService.updateStudent(updatedStudent);
      } catch (e) {
        // Will be synced later
      }
    }
  }

  Future<void> deleteStudent(String studentId) async {
    // Mark as inactive locally
    await LocalStorageService.deleteStudent(studentId);
    state = state.where((s) => s.id != studentId).toList();

    // Try to sync to Firebase
    if (await SyncService.isConnected()) {
      try {
        await FirebaseService.deleteStudent(studentId);
      } catch (e) {
        // Will be synced later
      }
    }
  }

  List<String> get batches {
    return state.map((s) => s.batch).toSet().toList()..sort();
  }

  List<Student> getStudentsByBatch(String batch) {
    return state.where((s) => s.batch == batch).toList();
  }
}