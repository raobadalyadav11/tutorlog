import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'payment.g.dart';

@HiveType(typeId: 3)
class Payment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String studentId;

  @HiveField(2)
  String tutorId;

  @HiveField(3)
  double amount;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String mode; // cash, upi, card

  @HiveField(6)
  String status; // Paid, Pending

  @HiveField(7)
  String? note;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  bool isSynced;

  @HiveField(10)
  String? transactionId;

  Payment({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.amount,
    required this.date,
    required this.mode,
    required this.status,
    this.note,
    required this.createdAt,
    this.isSynced = false,
    this.transactionId,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      tutorId: data['tutorId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      mode: data['mode'] ?? 'cash',
      status: data['status'] ?? 'Pending',
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isSynced: true,
      transactionId: data['transactionId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'tutorId': tutorId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'mode': mode,
      'status': status,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'transactionId': transactionId,
    };
  }
}