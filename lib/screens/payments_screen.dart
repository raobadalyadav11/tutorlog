import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('Collected', '₹8,500', AppTheme.secondaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard('Pending', '₹2,400', AppTheme.warningColor),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _getPayments().length,
              itemBuilder: (context, index) {
                final payment = _getPayments()[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: payment['status'] == 'Paid' 
                          ? AppTheme.secondaryColor 
                          : AppTheme.warningColor,
                      child: Icon(
                        payment['status'] == 'Paid' ? Icons.check : Icons.pending,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(payment['studentName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount: ₹${payment['amount']}'),
                        Text('Date: ${DateFormat('MMM dd, yyyy').format(payment['date'])}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        payment['status'],
                        style: TextStyle(
                          color: payment['status'] == 'Paid' ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: payment['status'] == 'Paid' 
                          ? AppTheme.secondaryColor 
                          : AppTheme.warningColor,
                    ),
                    isThreeLine: true,
                    onTap: payment['status'] == 'Pending' 
                        ? () => _showPaymentDialog(context, payment)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getPayments() {
    return [
      {
        'studentName': 'Rahul Sharma',
        'amount': 1500,
        'date': DateTime.now(),
        'status': 'Paid',
      },
      {
        'studentName': 'Priya Patel',
        'amount': 2000,
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'status': 'Pending',
      },
      {
        'studentName': 'Amit Kumar',
        'amount': 1500,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'status': 'Paid',
      },
      {
        'studentName': 'Sneha Singh',
        'amount': 1800,
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'status': 'Pending',
      },
    ];
  }

  void _showPaymentDialog(BuildContext context, Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark Payment - ${payment['studentName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount: ₹${payment['amount']}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: ['Cash', 'UPI', 'Bank Transfer'].map((mode) => 
                DropdownMenuItem(value: mode, child: Text(mode))
              ).toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment marked as paid')),
              );
            },
            child: const Text('Mark Paid'),
          ),
        ],
      ),
    );
  }
}