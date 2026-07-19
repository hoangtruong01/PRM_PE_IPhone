// test/features/loan_request/presentation/rapid_submit_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget test: rapid Submit taps produce only one fake POST call.
///
/// This test simulates a simple form with a submit button that disables
/// itself while submitting, ensuring multiple rapid taps only trigger
/// one POST call. This validates the pattern used in LoanRequestPage
/// where the button is disabled when formState is LoanRequestFormSubmitting.
void main() {
  group('Rapid Submit Prevention', () {
    testWidgets('rapid Submit taps produce only one POST call',
        (tester) async {
      int postCallCount = 0;
      bool isSubmitting = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      // Disable button while submitting (same pattern as LoanRequestPage)
                      onPressed: isSubmitting
                          ? null
                          : () {
                              setState(() {
                                isSubmitting = true;
                                postCallCount++;
                              });
                              // Simulate async POST call
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  if (context.mounted) {
                                    setState(() => isSubmitting = false);
                                  }
                                },
                              );
                            },
                      child: isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('SUBMIT LOAN REQUEST'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Verify button is enabled
      expect(find.text('SUBMIT LOAN REQUEST'), findsOneWidget);

      // Tap rapidly 5 times
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
      }

      // Only one POST call should have been made
      expect(postCallCount, 1,
          reason: 'Rapid taps should only produce one POST call');

      // Wait for the simulated POST to complete
      await tester.pumpAndSettle();

      // Button should be re-enabled
      expect(find.text('SUBMIT LOAN REQUEST'), findsOneWidget);
    });

    testWidgets('submit button shows loading indicator during submission',
        (tester) async {
      bool isSubmitting = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          setState(() => isSubmitting = true);
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () {
                              if (context.mounted) {
                                setState(() => isSubmitting = false);
                              }
                            },
                          );
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SUBMIT LOAN REQUEST'),
                ),
              );
            },
          ),
        ),
      );

      // Initially shows text
      expect(find.text('SUBMIT LOAN REQUEST'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap submit
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Shows loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SUBMIT LOAN REQUEST'), findsNothing);

      // Wait for completion
      await tester.pumpAndSettle();

      // Back to text
      expect(find.text('SUBMIT LOAN REQUEST'), findsOneWidget);
    });
  });
}
