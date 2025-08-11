import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'attendance.g.dart';

@HiveType(typeId: 2)
class Attendance extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String studentId;

  @HiveField(2)
  String tutorId;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  bool isPresent;

  @HiveField(5)
  String? note;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool isSynced;

  Attendance({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.date,
    required this.isPresent,
    this.note,
    required this.createdAt,
    this.isSynced = false,
  });

  factory Attendance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Attendance(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      tutorId: data['tutorId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isPresent: data['isPresent'] ?? false,
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'tutorId': tutorId,
      'date': Timestamp.fromDate(date),
      'isPresent': isPresent,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}