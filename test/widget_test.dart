// Smoke test PadelGo — memastikan landing page render dengan benar.

import 'package:flutter_test/flutter_test.dart';

import 'package:padel_go_app/main.dart';

void main() {
  testWidgets('PadelGo renders landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const PadelGoApp());
    await tester.pump();

    // Landing page menampilkan brand, hero title, dan CTA booking.
    expect(find.text('PadelGo'), findsWidgets);
    expect(find.text('PREMIUM COURTS'), findsOneWidget);
    expect(find.text('Booking Sekarang'), findsWidgets);
    expect(find.text('Siap Bermain?'), findsOneWidget);
  });
}
