// lib/features/loan_request/presentation/pages/request_result_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../equipment/presentation/pages/equipment_catalogue_page.dart'; // To use CampusBottomNavBar

/// Screen D — Request Result
/// Shows the loan request confirmation with data from the POST response.
/// Displays: Request ID, Device, Loan period, Deposit, Status.
class RequestResultPage extends ConsumerWidget {
  final Map<String, dynamic> resultData;

  const RequestResultPage({
    super.key,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const activeTeal = Color(0xFF0E9282);

    final isOffline = resultData['isOffline'] == true;
    final requestId = resultData['id']?.toString() ?? 'ff808181';
    final deviceName = resultData['deviceName']?.toString() ?? 'Unknown Device';
    final borrowDateStr = resultData['borrowDate']?.toString();
    final returnDateStr = resultData['returnDate']?.toString();
    final deposit = resultData['deposit'];

    // Parse dates
    DateTime? borrowDate;
    DateTime? returnDate;
    try {
      if (borrowDateStr != null) borrowDate = DateTime.parse(borrowDateStr);
      if (returnDateStr != null) returnDate = DateTime.parse(returnDateStr);
    } catch (_) {}

    // Format loan period to dd-dd MMM (e.g. 01-07 Aug)
    String loanPeriod = 'N/A';
    if (borrowDate != null && returnDate != null) {
      final startDay = borrowDate.day.toString().padLeft(2, '0');
      final endDay = returnDate.day.toString().padLeft(2, '0');
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthStr = months[borrowDate.month - 1];
      loanPeriod = '$startDay-$endDay $monthStr';
    }

    // Format deposit
    String depositStr = 'N/A';
    if (deposit != null) {
      if (deposit is num) {
        depositStr = '\$${deposit.toStringAsFixed(0)}';
      } else {
        depositStr = '\$$deposit';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28, color: Colors.black87),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'Request Result',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Checkmark Circle matching mockup D
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2F1), // Light green-teal bg
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: activeTeal,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title "Loan request created"
            const Text(
              'Loan request created',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle "Request ID #ff808181"
            Text(
              isOffline ? 'Saved locally (Pending Sync)' : 'Request ID #$requestId',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),

            // Details Container Box matching mockup D
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
              ),
              child: Column(
                children: [
                  _buildResultRow('Device', deviceName),
                  const Divider(height: 24, color: Color(0xFFF5F5F5)),
                  _buildResultRow('Loan period', loanPeriod),
                  const Divider(height: 24, color: Color(0xFFF5F5F5)),
                  _buildResultRow('Deposit', depositStr, valueColor: activeTeal),
                  const Divider(height: 24, color: Color(0xFFF5F5F5)),
                  _buildResultRow(
                    'Status', 
                    isOffline ? 'Pending Sync' : 'Pending approval', 
                    valueColor: activeTeal,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // BACK TO DEVICES button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'BACK TO DEVICES',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const CampusBottomNavBar(),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
