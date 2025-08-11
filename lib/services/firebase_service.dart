import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/tutor.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/payment.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await _messaging.requestPermission();
  }

  // Auth Methods
  static Future<String?> sendOTP(String phoneNumber) async {
    try {
      final completer = Completer<String?>();
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.complete(null);
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return await completer.future;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> verifyOTP(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  // Tutor Methods
  static Future<void> createTutor(Tutor tutor) async {
    await _firestore.collection('tutors').doc(tutor.id).set(tutor.toFirestore());
  }

  static Future<Tutor?> getTutor(String id) async {
    final doc = await _firestore.collection('tutors').doc(id).get();
    return doc.exists ? Tutor.fromFirestore(doc) : null;
  }

  static Future<void> updateTutor(Tutor tutor) async {
    await _firestore.collection('tutors').doc(tutor.id).update(tutor.toFirestore());
  }

  // Student Methods
  static Future<void> createStudent(Student student) async {
    await _firestore.collection('students').doc(student.id).set(student.toFirestore());
  }

  static Future<List<Student>> getStudents(String tutorId) async {
    final query = await _firestore
        .collection('students')
        .where('tutorId', isEqualTo: tutorId)
        .where('isActive', isEqualTo: true)
        .get();
    return query.docs.map((doc) => Student.fromFirestore(doc)).toList();
  }

  static Future<void> updateStudent(Student student) async {
    await _firestore.collection('students').doc(student.id).update(student.toFirestore());
  }

  static Future<void> deleteStudent(String studentId) async {
    await _firestore.collection('students').doc(studentId).update({'isActive': false});
  }

  // Attendance Methods
  static Future<void> createAttendance(Attendance attendance) async {
    await _firestore.collection('attendance').doc(attendance.id).set(attendance.toFirestore());
  }

  static Future<List<Attendance>> getAttendance(String tutorId, {DateTime? startDate, DateTime? endDate}) async {
    Query query = _firestore
        .collection('attendance')
        .where('tutorId', isEqualTo: tutorId);
    
    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final result = await query.get();
    return result.docs.map((doc) => Attendance.fromFirestore(doc)).toList();
  }

  static Future<void> updateAttendance(Attendance attendance) async {
    await _firestore.collection('attendance').doc(attendance.id).update(attendance.toFirestore());
  }

  // Payment Methods
  static Future<void> createPayment(Payment payment) async {
    await _firestore.collection('payments').doc(payment.id).set(payment.toFirestore());
  }

  static Future<List<Payment>> getPayments(String tutorId, {DateTime? startDate, DateTime? endDate}) async {
    Query query = _firestore
        .collection('payments')
        .where('tutorId', isEqualTo: tutorId);
    
    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final result = await query.get();
    return result.docs.map((doc) => Payment.fromFirestore(doc)).toList();
  }

  static Future<void> updatePayment(Payment payment) async {
    await _firestore.collection('payments').doc(payment.id).update(payment.toFirestore());
  }
}