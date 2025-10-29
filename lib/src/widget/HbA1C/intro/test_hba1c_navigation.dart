import 'package:flutter/material.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/widget/HbA1C/hba1c_navigation_helper.dart';

/// Test screen to verify HbA1C navigation logic
/// This can be removed after testing is complete
class TestHbA1cNavigation extends StatefulWidget {
  const TestHbA1cNavigation({Key? key}) : super(key: key);

  @override
  State<TestHbA1cNavigation> createState() => _TestHbA1cNavigationState();
}

class _TestHbA1cNavigationState extends State<TestHbA1cNavigation> {
  bool? isFirstTime;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeStatus();
  }

  Future<void> _checkFirstTimeStatus() async {
    final status = await AppStorages.isFirstTimeHbA1C();
    setState(() {
      isFirstTime = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test HbA1C Navigation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'HbA1C Navigation Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Status:'),
                  Text(
                    isFirstTime == null
                        ? 'Loading...'
                        : isFirstTime!
                            ? 'First time user (will show onboarding)'
                            : 'Returning user (will skip onboarding)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFirstTime == true ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await HbA1cNavigationHelper.navigateToHbA1C(context);
              },
              child: Text('Test HbA1C Navigation (Old Logic)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Test new glucose-like logic by simulating detail_hba1c navigation
                Navigator.pushNamed(context, '/home_v2_test', arguments: {
                  'test_route': 'detail_hba1c',
                  'simulate_no_data': !isFirstTime!,
                });
              },
              child: Text('Test New Glucose-like Logic'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await AppStorages.resetHbA1COnboarding();
                await _checkFirstTimeStatus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reset to first time user')),
                );
              },
              child: Text('Reset to First Time'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await AppStorages.setHbA1COnboardingCompleted();
                await _checkFirstTimeStatus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Set as returning user')),
                );
              },
              child: Text('Mark as Completed'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
