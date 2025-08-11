import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../models/tutor.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentTutorProvider = StateNotifierProvider<CurrentTutorNotifier, Tutor?>((ref) {
  return CurrentTutorNotifier();
});

class CurrentTutorNotifier extends StateNotifier<Tutor?> {
  CurrentTutorNotifier() : super(null);

  Future<void> loadCurrentTutor() async {
    final user = FirebaseService.currentUser;
    if (user != null) {
      // Try to get from local storage first
      Tutor? tutor = LocalStorageService.getTutor(user.uid);
      
      if (tutor == null) {
        // If not in local storage, get from Firebase
        tutor = await FirebaseService.getTutor(user.uid);
        if (tutor != null) {
          await LocalStorageService.saveTutor(tutor);
        }
      }
      
      state = tutor;
    }
  }

  Future<void> createTutor(String name, String phone) async {
    final user = FirebaseService.currentUser;
    if (user != null) {
      final tutor = Tutor(
        id: user.uid,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      );
      
      await FirebaseService.createTutor(tutor);
      await LocalStorageService.saveTutor(tutor);
      state = tutor;
    }
  }

  Future<void> updateSubscription(DateTime endDate) async {
    if (state != null) {
      final updatedTutor = Tutor(
        id: state!.id,
        name: state!.name,
        phone: state!.phone,
        subscriptionStatus: 'active',
        createdAt: state!.createdAt,
        subscriptionEndDate: endDate,
        isActive: state!.isActive,
      );
      
      await FirebaseService.updateTutor(updatedTutor);
      await LocalStorageService.saveTutor(updatedTutor);
      state = updatedTutor;
    }
  }

  void signOut() {
    state = null;
  }
}