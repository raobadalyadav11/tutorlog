import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'student.g.dart';

@HiveType(typeId: 1)
class Student extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String tutorId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String batch;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  String? parentName;

  @HiveField(6)
  DateTime joinDate;

  @HiveField(7)
  double monthlyFee;

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  DateTime? lastSyncAt;

  Student({
    required this.id,
    required this.tutorId,
    required this.name,
    required this.batch,
    this.phone,
    this.parentName,
    required this.joinDate,
    required this.monthlyFee,
    this.isActive = true,
    this.lastSyncAt,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      tutorId: data['tutorId'] ?? '',
      name: data['name'] ?? '',
      batch: data['batch'] ?? '',
      phone: data['phone'],
      parentName: data['parentName'],
      joinDate: (data['joinDate'] as Timestamp).toDate(),
      monthlyFee: (data['monthlyFee'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
      lastSyncAt: data['lastSyncAt'] != null
          ? (data['lastSyncAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tutorId': tutorId,
      'name': name,
      'batch': batch,
      'phone': phone,
      'parentName': parentName,
      'joinDate': Timestamp.fromDate(joinDate),
      'monthlyFee': monthlyFee,
      'isActive': isActive,
      'lastSyncAt': lastSyncAt != null
          ? Timestamp.fromDate(lastSyncAt!)
          : null,
    };
  }
}