import 'package:hive_flutter/hive_flutter.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/payment.dart';

class StorageService {
  static const String studentsBox = 'students';
  static const String attendanceBox = 'attendance';
  static const String paymentsBox = 'payments';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(StudentAdapter());
    Hive.registerAdapter(AttendanceAdapter());
    Hive.registerAdapter(PaymentAdapter());
    
    await Hive.openBox<Student>(studentsBox);
    await Hive.openBox<Attendance>(attendanceBox);
    await Hive.openBox<Payment>(paymentsBox);
  }

  static Box<Student> get students => Hive.box<Student>(studentsBox);
  static Box<Attendance> get attendance => Hive.box<Attendance>(attendanceBox);
  static Box<Payment> get payments => Hive.box<Payment>(paymentsBox);
}