import 'package:flutter_test/flutter_test.dart';
import 'package:enterprise_ticket_management_system/main.dart';

void main() {
  testWidgets('Enterprise Ticket System smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EnterpriseTicketApp());
    expect(find.text('ENTERPRISE'), findsOneWidget);
  });
}
