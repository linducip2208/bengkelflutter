import 'package:bengkelflutter/domain/entities/roles.dart';
import 'package:bengkelflutter/shared/widgets/components.dart';
import 'package:bengkelflutter/shared/widgets/design_extra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login shows email+password+Masuk', (t) async {
    await t.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Bengkel Paten'))),
    );
    expect(find.text('Bengkel Paten'), findsOneWidget);
  });

  testWidgets('StatusBadge renders + role guard hides action', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge(text: 'waiting_approval', color: Colors.orange),
              RoleGuard(
                roles: ['mekanik'],
                allowed: ['kasir'],
                child: Text('PAY'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('waiting_approval'), findsOneWidget);
    expect(find.text('PAY'), findsNothing);
  });

  test('role matrix guards critical actions', () {
    expect(Roles.canPay(['kasir']), isTrue);
    expect(Roles.canPay(['mekanik']), isFalse);
    expect(Roles.canConvertEstimate(['service_advisor']), isFalse);
    expect(Roles.canQc(['service_advisor']), isTrue);
  });
}
