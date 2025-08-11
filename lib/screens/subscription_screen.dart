import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    final tutor = ref.watch(currentTutorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          tutor?.hasActiveSubscription == true ? Icons.check_circle : Icons.warning,
                          color: tutor?.hasActiveSubscription == true ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text('Subscription Status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Status: ${tutor?.hasActiveSubscription == true ? 'Active' : 'Inactive'}'),
                    if (tutor?.subscriptionEndDate != null)
                      Text('Valid until: ${tutor!.subscriptionEndDate!.day}/${tutor.subscriptionEndDate!.month}/${tutor.subscriptionEndDate!.year}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Plan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('₹9', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        Text('/month', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('✓ Unlimited students'),
                    const Text('✓ Attendance tracking'),
                    const Text('✓ Payment management'),
                    const Text('✓ Export reports'),
                    const Text('✓ Offline sync'),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: tutor?.hasActiveSubscription == true ? null : _startPayment,
                        child: Text(tutor?.hasActiveSubscription == true ? 'Already Subscribed' : 'Subscribe Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startPayment() {
    final tutor = ref.read(currentTutorProvider);
    if (tutor == null) return;

    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': 900,
      'name': 'TutorLog',
      'description': 'Monthly Subscription',
      'prefill': {'contact': tutor.phone, 'email': '${tutor.phone}@tutorlog.com'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed')));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final endDate = DateTime.now().add(const Duration(days: 30));
    ref.read(currentTutorProvider.notifier).updateSubscription(endDate);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful!'), backgroundColor: Colors.green));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: ${response.message}')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('External wallet: ${response.walletName}')));
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}