import 'package:flutter_test/flutter_test.dart';
import 'package:remind_me/core/app.dart';
import 'package:remind_me/views/pages/date/date_page.dart';

void main() {
  testWidgets('App should render HomePage with DatePage initially', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const RemindMeApp());

    // Verify that DatePage is shown initially (index 0 in bottom nav)
    expect(find.byType(DatePage), findsOneWidget);
  });
}
