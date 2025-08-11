import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/payment.dart';
import '../services/storage_service.dart';

final studentsProvider = StateNotifierProvider<StudentsNotifier, List<Student>>((ref) {
  return StudentsNotifier();
});

class StudentsNotifier extends StateNotifier<List<Student>> {
  StudentsNotifier() : super([]) {
    _loadStudents();
  }

  void _loadStudents() {
    state = StorageService.students.values.toList();
  }

  void addStudent(Student student) {
    StorageService.students.put(student.id, student);
    state = [...state, student];
  }

  void removeStudent(String id) {
    StorageService.students.delete(id);
    state = state.where((student) => student.id != id).toList();
  }

  void updateStudent(Student updatedStudent) {
    StorageService.students.put(updatedStudent.id, updatedStudent);
    state = [
      for (final student in state)
        if (student.id == updatedStudent.id) updatedStudent else student,
    ];
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, List<Attendance>>((ref) {
  return AttendanceNotifier();
});

class AttendanceNotifier extends StateNotifier<List<Attendance>> {
  AttendanceNotifier() : super([]) {
    _loadAttendance();
  }

  void _loadAttendance() {
    state = StorageService.attendance.values.toList();
  }

  void markAttendance(Attendance attendance) {
    StorageService.attendance.put(attendance.id, attendance);
    state = [...state, attendance];
  }

  List<Attendance> getAttendanceForDate(DateTime date) {
    return state.where((a) => 
      a.date.year == date.year && 
      a.date.month == date.month && 
      a.date.day == date.day
    ).toList();
  }
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, List<Payment>>((ref) {
  return PaymentsNotifier();
});

class PaymentsNotifier extends StateNotifier<List<Payment>> {
  PaymentsNotifier() : super([]) {
    _loadPayments();
  }

  void _loadPayments() {
    state = StorageService.payments.values.toList();
  }

  void addPayment(Payment payment) {
    StorageService.payments.put(payment.id, payment);
    state = [...state, payment];
  }

  double getTotalCollected() {
    return state.where((p) => p.status == 'Paid').fold(0.0, (sum, p) => sum + p.amount);
  }

  double getTotalPending() {
    return state.where((p) => p.status == 'Pending').fold(0.0, (sum, p) => sum + p.amount);
  }
}