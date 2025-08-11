import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../providers/auth_provider.dart';
import 'profile_setup_screen.dart';
import '../dashboard_screen.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.message,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Enter OTP',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a verification code to\n${widget.phoneNumber}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                labelText: 'Enter 6-digit OTP',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              maxLength: 6,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify OTP'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Change Phone Number'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      _showError('Please enter 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await FirebaseService.verifyOTP(
        widget.verificationId,
        _otpController.text.trim(),
      );

      if (user != null) {
        // Check if tutor profile exists
        final tutor = await FirebaseService.getTutor(user.uid);
        
        if (tutor == null) {
          // New user - go to profile setup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileSetupScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        } else {
          // Existing user - load profile and go to dashboard
          await ref.read(currentTutorProvider.notifier).loadCurrentTutor();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else {
        _showError('Invalid OTP. Please try again.');
      }
    } catch (e) {
      _showError('Verification failed. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}