import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_tracker/main.dart';

void main() {
  testWidgets('App starts and shows Med Tracker title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MedTrackerApp()));
    await tester.pumpAndSettle();

    expect(find.text('Med Tracker'), findsOneWidget);
  });
}