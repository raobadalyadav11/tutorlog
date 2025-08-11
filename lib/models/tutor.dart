import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'tutor.g.dart';

@HiveType(typeId: 0)
class Tutor extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String subscriptionStatus;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? subscriptionEndDate;

  @HiveField(6)
  bool isActive;

  Tutor({
    required this.id,
    required this.name,
    required this.phone,
    this.subscriptionStatus = 'inactive',
    required this.createdAt,
    this.subscriptionEndDate,
    this.isActive = true,
  });

  factory Tutor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tutor(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      subscriptionStatus: data['subscriptionStatus'] ?? 'inactive',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      subscriptionEndDate: data['subscriptionEndDate'] != null
          ? (data['subscriptionEndDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'subscriptionStatus': subscriptionStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'subscriptionEndDate': subscriptionEndDate != null
          ? Timestamp.fromDate(subscriptionEndDate!)
          : null,
      'isActive': isActive,
    };
  }

  bool get hasActiveSubscription {
    return subscriptionStatus == 'active' &&
        subscriptionEndDate != null &&
        subscriptionEndDate!.isAfter(DateTime.now());
  }
}