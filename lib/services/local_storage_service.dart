import 'package:hive_flutter/hive_flutter.dart';
import '../models/tutor.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/payment.dart';

class LocalStorageService {
  static late Box<Tutor> _tutorBox;
  static late Box<Student> _studentBox;
  static late Box<Attendance> _attendanceBox;
  static late Box<Payment> _paymentBox;
  static late Box _settingsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(TutorAdapter());
    Hive.registerAdapter(StudentAdapter());
    Hive.registerAdapter(AttendanceAdapter());
    Hive.registerAdapter(PaymentAdapter());

    // Open boxes
    _tutorBox = await Hive.openBox<Tutor>('tutors');
    _studentBox = await Hive.openBox<Student>('students');
    _attendanceBox = await Hive.openBox<Attendance>('attendance');
    _paymentBox = await Hive.openBox<Payment>('payments');
    _settingsBox = await Hive.openBox('settings');
  }

  // Tutor Methods
  static Future<void> saveTutor(Tutor tutor) async {
    await _tutorBox.put(tutor.id, tutor);
  }

  static Tutor? getTutor(String id) {
    return _tutorBox.get(id);
  }

  static Future<void> deleteTutor(String id) async {
    await _tutorBox.delete(id);
  }

  // Student Methods
  static Future<void> saveStudent(Student student) async {
    await _studentBox.put(student.id, student);
  }

  static List<Student> getStudents(String tutorId) {
    return _studentBox.values
        .where((student) => student.tutorId == tutorId && student.isActive)
        .toList();
  }

  static Student? getStudent(String id) {
    return _studentBox.get(id);
  }

  static Future<void> deleteStudent(String id) async {
    final student = _studentBox.get(id);
    if (student != null) {
      student.isActive = false;
      await _studentBox.put(id, student);
    }
  }

  // Attendance Methods
  static Future<void> saveAttendance(Attendance attendance) async {
    await _attendanceBox.put(attendance.id, attendance);
  }

  static List<Attendance> getAttendance(String tutorId, {DateTime? startDate, DateTime? endDate}) {
    var attendance = _attendanceBox.values
        .where((a) => a.tutorId == tutorId)
        .toList();

    if (startDate != null) {
      attendance = attendance.where((a) => a.date.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
    }
    if (endDate != null) {
      attendance = attendance.where((a) => a.date.isBefore(endDate.add(const Duration(days: 1)))).toList();
    }

    return attendance;
  }

  static List<Attendance> getUnsyncedAttendance() {
    return _attendanceBox.values.where((a) => !a.isSynced).toList();
  }

  static Future<void> markAttendanceSynced(String id) async {
    final attendance = _attendanceBox.get(id);
    if (attendance != null) {
      attendance.isSynced = true;
      await _attendanceBox.put(id, attendance);
    }
  }

  // Payment Methods
  static Future<void> savePayment(Payment payment) async {
    await _paymentBox.put(payment.id, payment);
  }

  static List<Payment> getPayments(String tutorId, {DateTime? startDate, DateTime? endDate}) {
    var payments = _paymentBox.values
        .where((p) => p.tutorId == tutorId)
        .toList();

    if (startDate != null) {
      payments = payments.where((p) => p.date.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
    }
    if (endDate != null) {
      payments = payments.where((p) => p.date.isBefore(endDate.add(const Duration(days: 1)))).toList();
    }

    return payments;
  }

  static List<Payment> getUnsyncedPayments() {
    return _paymentBox.values.where((p) => !p.isSynced).toList();
  }

  static Future<void> markPaymentSynced(String id) async {
    final payment = _paymentBox.get(id);
    if (payment != null) {
      payment.isSynced = true;
      await _paymentBox.put(id, payment);
    }
  }

  // Settings Methods
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  static Future<void> clearAllData() async {
    await _tutorBox.clear();
    await _studentBox.clear();
    await _attendanceBox.clear();
    await _paymentBox.clear();
    await _settingsBox.clear();
  }
}